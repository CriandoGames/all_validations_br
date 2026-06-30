# Changelog

## 4.5.0

### Criptografia — qualidade e ergonomia

#### `CryptAlgorithm` — novo enum público

O campo `algorithm` do `EncryptedPayload` passou de `String` para o enum
fortemente tipado `CryptAlgorithm`, com autocomplete e exaustividade
garantida pelo compilador no `switch`:

```dart
// Antes (string literal sem autocomplete)
EncryptedPayload(algorithm: 'aes-cbc', ...)

// Agora (enum com autocomplete e type-safety)
EncryptedPayload(algorithm: CryptAlgorithm.aesCbc, ...)
```

Valores disponíveis: `chacha20Poly1305`, `aesGcm`, `aesCbc`, `aesCtr`.
Cada case expõe `.value` (string JSON) e `CryptAlgorithm.fromString()` para
desserialização retrocompatível.

`CryptUtil.decryptAny` agora usa `switch` exaustivo — o compilador garante que
todo algoritmo suportado está coberto, sem necessidade de cláusula `default`.

#### `EncryptedPayload` — `tag` e `aad` opcionais

Os campos `tag` e `aad` agora são opcionais no construtor e assumem
`Uint8List(0)` quando omitidos. Elimina boilerplate em modos sem autenticação:

```dart
// Antes
EncryptedPayload(
  algorithm:  CryptAlgorithm.aesCbc,
  ciphertext: base64.decode(ct),
  key:        key,
  nonce:      iv,
  tag:        Uint8List(0),   // obrigatório, mas sempre vazio em CBC/CTR
  aad:        Uint8List(0),   // idem
);

// Agora
EncryptedPayload(
  algorithm:  CryptAlgorithm.aesCbc,
  ciphertext: base64.decode(ct),
  key:        key,
  nonce:      iv,
);
```

Código existente que passa `tag`/`aad` explicitamente continua funcionando.

#### Correção de bug — Inc128 / Inc32 em `Uint8List` (AES-CTR e AES-GCM)

`++ctr[i]` em Dart retorna o valor pré-truncagem (ex.: `256` quando o byte
vale `0xff`), o que impedia o carry de propagar corretamente no incremento
big-endian do contador. O bug afetava:

- **AES-CTR**: blocos 2+ do ciphertext incorretos quando qualquer byte do
  contador transbordava de `0xff` para `0x00`.
- **AES-GCM `_inc32` / `_gctr`**: mesma condição nos últimos 4 bytes; não
  manifestado nos testes NIST anteriores porque nenhum contador chegava a `0xff`.

Correção aplicada em `aes_ctr.dart` e `aes_gcm.dart`:

```dart
// Antes (bug: verifica valor pré-truncagem)
if (++ctr[i] != 0) break;

// Depois (correto: verifica valor já truncado a 8 bits)
ctr[i]++;
if (ctr[i] != 0) break;
```

Todos os vetores NIST SP 800-38A F.5.1 (AES-128-CTR) e F.5.5 (AES-256-CTR)
passam após a correção.

#### Documentação

- `EncryptedPayload` ganhou dartdoc detalhado por campo, com tabela de tamanhos
  por algoritmo, exemplo de interop com APIs externas (Flavors / `.env`) e
  orientação sobre quando construir manualmente vs. usar `CryptUtil`.
- `CryptAlgorithm` documentado com dartdoc por case.
- README atualizado: nova seção `🔐 Criptografia` com tabela de algoritmos,
  exemplos de todos os métodos e badge de total de testes (1110).

---

## 4.4.0

### Módulo de criptografia expandido — puro Dart, zero dependências

Implementação completa de criptografia simétrica, hash e MAC em Dart puro
(apenas `dart:typed_data`, `dart:math`, `dart:convert`), seguindo as especificações
NIST / RFC com vetores de teste verificados via Python `cryptography`.

#### Novos algoritmos

| Algoritmo | Spec | Classe |
|-----------|------|--------|
| SHA-256 | FIPS 180-4 | `sha256()` |
| HMAC-SHA256 | RFC 2104 / RFC 4231 | `hmacSha256()`, `hmacEqual()` |
| AES-GCM (AEAD) | NIST SP 800-38D | `AesGcm` |
| AES-CBC + PKCS#7 | NIST SP 800-38A | `AesCbc` |
| AES-CTR + Inc128 | NIST SP 800-38A | `AesCtr` |

Suporte a AES-128 (chave 16 bytes) e AES-256 (chave 32 bytes) em todos os modos AES.

#### CryptUtil — API unificada ampliada

```dart
// AES-256-GCM (AEAD)
final payload = CryptUtil.encryptAesGcm(bytes, key: key);
final plain   = CryptUtil.decryptAesGcm(payload);

// AES-CBC
final payload = CryptUtil.encryptAesCbc(bytes, key: key);
final plain   = CryptUtil.decryptAesCbc(payload);

// AES-CTR
final payload = CryptUtil.encryptAesCtr(bytes, key: key);
final plain   = CryptUtil.decryptAesCtr(payload);

// Dispatch automático pelo campo algorithm
final plain = CryptUtil.decryptAny(payload);

// Geração de material criptográfico
final key32 = CryptUtil.generateKey();      // 32 bytes (AES-256 / ChaCha20)
final key16 = CryptUtil.generateKey128();   // 16 bytes (AES-128)
final nonce = CryptUtil.generateNonce();    // 12 bytes (GCM / ChaCha20)
final iv    = CryptUtil.generateIv();       // 16 bytes (CBC / CTR)
```

#### EncryptedPayload — campo `algorithm`

O modelo [EncryptedPayload] ganhou o campo `algorithm` (retrocompatível —
payloads antigos sem o campo assumem `'chacha20-poly1305'`).

#### Novo barrel `crypt.dart`

```dart
// Para projetos que usam apenas o módulo de criptografia:
import 'package:all_validations_br/crypt.dart';
```

#### Testes

Todos os algoritmos novos possuem testes unitários com vetores de referência
verificados por Python `cryptography` / OpenSSL:

- `test/sha256_test.dart` — NIST FIPS 180-4 + RFC 4231 (HMAC)
- `test/aes_gcm_test.dart` — NIST SP 800-38D
- `test/aes_cbc_ctr_test.dart` — NIST SP 800-38A (F.2 CBC, F.5 CTR)

---

## 4.3.0

### 🎭 ExpiryMask — Nova máscara para data de expiração (MM/AA e MM/AAAA)

Nova classe `ExpiryMask` para campos de data de expiração que aceitam tanto ano com 2 quanto com 4 dígitos (documentos, passaportes, CNH).

```dart
TextField(
  inputFormatters: [ExpiryMask()],
)
```

| Entrada    | Saída       | Formato   |
|------------|-------------|-----------|
| `'1224'`   | `'12/24'`   | MM/AA     |
| `'12245'`  | `'12/245'`  | MM/AAA    |
| `'122024'` | `'12/2024'` | MM/AAAA   |
| `'1220249'`| `'12/2024'` | truncado no 6° dígito |

Para campos de cartão de crédito/débito, continue usando `CardExpiryMask` — que já suporta MM/AA e MM/AAAA e permanece inalterada.

---

### 🐛 Correções de testes — valores de exemplo inválidos

Corrigidos valores de exemplo nos testes unitários que não satisfaziam os algoritmos já implementados (os algoritmos estavam corretos; os dados de teste estavam errados):

| Validador | Valor anterior (inválido) | Valor corrigido |
|---|---|---|
| `isRenavam` — 11 dígitos | `'97832655694'` | `'97832655697'` |
| `isRenavam` — 9 dígitos | `'732655694'` | `'732655692'` |
| `isTituloEleitor` — SP (cod 01) | `'906701490856'` | `'123456780191'` |
| `isCns` — definitivo | `'700616457492003'` | `'700616457492001'` |
| `isCns` — provisório | `'144477462150010'` | `'144477462150004'` |
| `CnpjAlfanumerico.format` — input | `'AB1234567800AB99'` (16 chars) | `'AB1234567800AB'` (14 chars) |

Nenhuma lógica de validação foi alterada.

---

### ⚠️ Breaking change — `isPlaca` não normaliza entrada para maiúsculas

**Antes (4.2.0):**
```dart
isPlaca('abc1234'); // true  ← convertia para 'ABC1234' internamente
```

**Depois (4.3.0):**
```dart
isPlaca('abc1234'); // false ← valida o valor como recebido
isPlaca('ABC1234'); // true
```

**Impacto:** código que passa strings com letras minúsculas para `isPlaca` e espera `true` precisa normalizar a entrada antes:

```dart
// Migração: normalize antes de chamar
isPlaca(value.toUpperCase()); // comportamento equivalente ao anterior
```

**Motivação:** placas brasileiras são sempre maiúsculas por definição (DENATRAN/SENATRAN). A normalização silenciosa escondia entradas malformadas, o que é inconsistente com o comportamento dos demais validadores da biblioteca (nenhum outro normaliza silenciosamente).

---

## 4.2.0

### 🧩 Extensions — Extensões null-safe em tipos nativos

Novo módulo `src/extensions/` com extensões Dart sobre `bool?`, `String?` e `List<T>?`. Disponível automaticamente via importação padrão — nenhuma importação adicional necessária.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

#### BoolExtension

Getters semânticos em `bool?` que diferenciam explicitamente `true`, `false` e `null` sem lançar exceções.

```dart
bool? ativo = true;
ativo.isTrue;   // true
ativo.isFalse;  // false

bool? indefinido = null;
indefinido.isTrue;  // false — null seguro
indefinido.isFalse; // false — null seguro
```

#### StringExtension

Verificação de nulidade/vazio e truncagem de texto em `String?`.

| Getter / Método | Comportamento |
|---|---|
| `isNullOrEmpty` | `true` se `null` ou `''` — espaços **não** são vazios |
| `isNotNullOrEmpty` | inverso de `isNullOrEmpty` |
| `isNullOrEmptyWithSpace` | `true` se `null`, `''` ou só espaços (usa `trim()`) |
| `isNotNullOrEmptyWithSpace` | inverso de `isNullOrEmptyWithSpace` |
| `truncate(int maxLength)` | trunca ao limite e adiciona `'...'`; null-safe |

```dart
'  Carlos  '.isNullOrEmptyWithSpace;   // false
'   '.isNullOrEmptyWithSpace;          // true
'Flutter é incrível'.truncate(7);      // 'Flutter...'
```

#### ListExtension

Verificação de nulidade/vazio em `List<T>?`.

```dart
List<String>? erros = null;
erros.isNullOrEmpty;    // true
erros.isNotNullOrEmpty; // false

['CPF inválido'].isNotNullOrEmpty; // true
```

**Testes:** 25 casos em `test/extensions/extensions_test.dart`.

**Documentação:** [📄 Extensions.md](doc/Extensions.md)

---

> ⚠️ **Breaking change:** nenhum. Toda a API anterior permanece inalterada.

---

## 4.1.0

### 🔍 BrZod — Validador Fluente

Novo módulo de validação fluente/encadeado com foco em documentos brasileiros. Importação separada, zero dependências externas, autocontido e estruturado para eventual extração como pacote standalone.

```dart
import 'package:all_validations_br/br_zod.dart';
```

**30 métodos encadeáveis:**

- **Genéricos:** `required`, `optional`, `min`, `max`, `email`, `phone`, `equals`, `type<T>`, `isDate`, `isBefore`, `isAfter`, `custom`
- **Documentos BR:** `cpf`, `cnpj`, `cnpjAlfa`, `cpfOuCnpj`, `cep`, `rg`, `placa`, `cnh`, `renavam`, `pisPasep`, `tituloEleitor`, `cns`
- **Segurança:** `password`, `uuid`, `url`, `ipv4`, `ipv6`, `regex`

**`PasswordPolicy`** — política de senha configurável com presets `weak`, `medium` e `strong`, ou totalmente customizável.

**`BrZod.validate()`** — valida `Map<String, dynamic>` contra um esquema de validators. Suporta Maps aninhados e retorna `BrZodResult` com `errors` (estruturado) e `errorList` (notação de ponto, ex: `user.email: ...`).

**Locale customizado** — `BrZod.defaultLocale` para configuração global ou `BrZod(locale:)` por instância. Interface `ILocaleBrZod` para tradução completa das 30 mensagens.

**Testes:** 126 casos distribuídos em `br_zod_generic_test.dart`, `br_zod_br_test.dart`, `br_zod_security_test.dart` e `br_zod_integration_test.dart`.

**Documentação:** [📄 BrZod.md](doc/BrZod.md)

---

### 📋 BrLogger — Logging Puro para Dart/Flutter

Novo módulo de logging zero dependências. Funciona em Flutter e Dart server-side. Importação separada — não interfere no resto da biblioteca.

```dart
import 'package:all_validations_br/br_logger.dart';
```

**6 níveis de log:** `trace`, `debug`, `info`, `warning`, `error`, `fatal`.

**Pipeline plugável:** `BrLogFilter` → `BrLogPrinter` → `BrLogOutput` — cada etapa é substituível.

**Padrão out-of-the-box:** tudo visível em debug, apenas `warning+` em produção. Printers com cores ANSI, output para `print()` e DevTools.

**Documentação:** [📄 BrLogger.md](doc/BrLogger.md)

---

> ⚠️ **Breaking change:** nenhum. Toda a API anterior permanece inalterada. Os novos módulos usam importações separadas (`br_zod.dart`, `br_logger.dart`) e não conflitam com `all_validations_br.dart`.
---

## 4.0.5
### 🎭 Novos Formatters

- **`CestMask`** — Código Especificador da Substituição Tributária: `12.345.67` (7 dígitos).
- **`IofMask`** — Alíquota de IOF com 6 casas decimais: `1,234567` (7 dígitos, entrada esquerda-direita).
- **`NupMask`** — Número Único de Protocolo federal: `1234567-89.0123.4.56.7890` (20 dígitos).
- **`CertNascimentoMask`** — Certidão de Nascimento: `000000 11 22 3333 4 55555 666 7777777 88` (32 dígitos).

**Testes:** 38 casos adicionados em `test/masks/cest_iof_nup_cert_mask_test.dart`.

> ⚠️ **Breaking change:** nenhum.

---

## 4.0.4
### 📚 Documentação

Revisão e enriquecimento completo da documentação técnica. Nenhuma mudança de API ou comportamento.

**Nova estrutura `docs/` — documentação detalhada por classe:**


---

## 4.0.3
### 📝 Documentação
- Refatoração do README: eliminada duplicação de conteúdo entre as seções ⚙️ Funcionalidades e 🆘 Classes para Uso. Nenhuma mudança de API ou comportamento.

---

## 4.0.2
### 🎭 Novos Formatters 

- **`CardExpiryMask` atualizada** — agora suporta dois formatos de forma dinâmica: `MM/AA` (até 4 dígitos) e `MM/AAAA` (5–6 dígitos). Retrocompatível.
- **`KmMask`** — quilometragem com separador de milhar (`.`). Máx 7 dígitos (`9.999.999 km`). Remove zeros à esquerda.
- **`CentavosMask`** — variante da `CurrencyMask` sem prefixo `R$`. Entrada right-to-left em centavos.
- **`NcmMask`** — Nomenclatura Comum do Mercosul: `1234.56.78` (8 dígitos).
- **`CnsMask`** — Cartão Nacional de Saúde: `111 2222 3333 4444` (15 dígitos).
- **`AlturaMask`** — `X,XX` — ex: `175` → `1,75`.
- **`PesoMask`** — `XXX,X` — ex: `7051` → `705,1`.
- **`TemperaturaMask`** — `XX,X` — ex: `365` → `36,5`.

**Testes:** 70+ casos adicionados em 5 novos arquivos de teste.

> ⚠️ **Breaking change:** nenhum.

---

## 4.0.1
### 🔧 Correções
- **Correção de Documentação**
---

## 4.0.0
**10 formatters prontos para uso:**

| Classe | Máscara | Dígitos máx |
|---|---|---|
| `CpfMask` | `999.999.999-99` | 11 |
| `CnpjMask` | `99.999.999/9999-99` | 14 |
| `CnpjAlfaMask` | `AA.123.CDE/0001-39` | 14 |
| `PhoneMask` | `(99) 9999-9999` / `(99) 99999-9999` | 10/11 |
| `CepMask` | `99999-999` | 8 |
| `DateMask` | `DD/MM/AAAA` | 8 |
| `TimeMask` | `HH:MM` | 4 |
| `CurrencyMask` | `R$ 1.234,56` | 13 |
| `CardMask` | `9999 9999 9999 9999` | 16 |
| `CardExpiryMask` | `MM/AA` | 4 |

**Destaques técnicos:**
- `PhoneMask`: detecta automaticamente fixo vs celular — o traço migra de posição 6 para 7 quando o 11° dígito é inserido.
- `CnpjAlfaMask`: converte automaticamente para maiúsculas, aceita letras e dígitos, compatível com o novo padrão CNPJ alfanumérico 2026.
- `CurrencyMask`: abordagem *right-to-left* — sempre mostra `R$ X.XXX,XX`; overflow limitado aos últimos 13 dígitos.
- Todos os construtores são `const` — instanciação de custo zero.
- `static final RegExp` — compilado uma única vez, reutilizado em todas as chamadas.

**Testes:** 134+ casos distribuídos em 6 arquivos (`test/masks/`), cobrindo progressão da máscara, truncamento, filtragem de caracteres e posição do cursor.

**Exemplo interativo** adicionado em `example/lib/main.dart` — seção com 10 `TextField`s ao vivo.

> ⚠️ **Breaking change:** nenhum. Toda a API anterior permanece inalterada. Esta versão é major pelo volume e relevância das adições.

---

## 3.4.0
### 🆕 Novas Funcionalidades

* **Criptografia autenticada ChaCha20-Poly1305** (`CryptUtil`) — implementação Dart pura, sem dependências externas, conforme RFC 8439.
  - `CryptUtil.encryptText(text, {key?, nonce?, aad?})` — cifra uma String UTF-8 e retorna `EncryptedPayload`.
  - `CryptUtil.decryptText(payload)` — decifra e retorna a String original.
  - `CryptUtil.encryptBytes(bytes, {key?, nonce?, aad?})` — cifra dados binários (`List<int>`).
  - `CryptUtil.decryptBytes(payload)` — decifra e retorna `List<int>`.
  - `CryptUtil.encryptToBase64(text, {key?, nonce?, aad?})` — atalho que cifra e serializa o payload como string base64 única.
  - `CryptUtil.decryptFromBase64(encoded)` — atalho que deserializa e decifra de base64.
  - `CryptUtil.generateKey()` — gera chave de 32 bytes via `Random.secure`.
  - `CryptUtil.generateNonce()` — gera nonce de 12 bytes via `Random.secure`.

* **`EncryptedPayload`** — modelo de resultado com suporte a serialização.
  - `toJson()` / `fromJson()` — serialização como `Map<String, dynamic>` (campos em base64).
  - `toBase64()` / `fromBase64()` — serialização como string base64 compacta.

* **`CryptException`** — exceção lançada quando a tag de autenticação Poly1305 não confere, indicando dados corrompidos ou chave incorreta.

### 🔧 Outros

* `pubspec.yaml` — descrição atualizada para refletir os três pilares da biblioteca: validações, utilitários e criptografia.
* `README.md` — nova seção "📱 App de Exemplo" e seção completa "🔒 Criptografia Autenticada" com referência da API, exemplos de uso, serialização, AAD e boas práticas.
* `example/lib/main.dart` — adicionadas demos interativas de `HelperUtil` e `CryptUtil` (encriptação/decriptação e simulação de adulteração).
* `test/crypt_util_test.dart` — 21 casos de teste cobrindo round-trip texto/bytes, nonces aleatórios, serialização JSON/base64, detecção de adulteração em ciphertext/tag/nonce, AAD mismatch e parâmetros inválidos.

> ⚠️ **Sem breaking changes.** Toda a API existente permanece inalterada.

---

## 3.3.1
### 🔧 Correções
* Corrigido casing da pasta `Notifications` → `notifications` para compatibilidade com sistemas Linux (pub.dev).
* Removido `dart:io` do `HelperUtil` — substituído por `flutter/foundation.dart`, habilitando suporte a todas as plataformas (iOS, Android, Web, Windows, macOS, Linux).

---

## 3.3.0
### 🆕 Novas Funcionalidades

* **Validação de Chaves PIX** (`HelperUtil.validatePixKey`)
  - Identifica o tipo da chave PIX: CPF, Celular, E-mail ou Chave Aleatória.
  - Segue a ordem de validação definida pelo BACEN.
  - Otimização: descarta e-mail e chave aleatória imediatamente quando o input contém apenas dígitos.

* **Mascaramento de Chave PIX** (`HelperUtil.maskPixKey`)
  - Mascara a chave PIX para exibição segura ao usuário.
  - Ex: CPF `99286479174` → `992.***.***-74`, Celular `+5511912345678` → `+5511*****678`.

* **Validação de Documentos Brasileiros**
  - `isCnh`: Valida CNH com cálculo dos dois dígitos verificadores.
  - `isRenavam`: Valida RENAVAM de 9 ou 11 dígitos com dígito verificador.
  - `isPisPasep`: Valida PIS/PASEP com dígito verificador.
  - `isTituloEleitor`: Valida Título de Eleitor com dois dígitos verificadores e estado.

* **Utilitários de data e idade** (`HelperUtil`)
  - `isAdult`: Verifica se uma data de nascimento corresponde a maior de idade (padrão 18 anos, customizável).
  - `isValidDate`: Verifica se uma data realmente existe (ex: `31/02` retorna `false`). Aceita `dd/MM/yyyy` e `yyyy-MM-dd`.

### 🔧 Correções

* **`validatePixKey`** — CPF agora valida dígitos verificadores via `AllValidations.isCpf` (antes aceitava qualquer 11 dígitos).
* **`validatePixKey`** — Celular corrigido para exigir formato E.164 com `9` após o DDD (`+55XXXXXXXXXXX`).
* **`validatePixKey`** — Chave aleatória corrigida para UUID v4 com hífens (`xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`), conforme padrão BACEN.
* **`validatePixKey`** — Removido `;` solto após bloco de e-mail.
* **`isDigit`** — Removida declaração duplicada de variável e corrigida referência `cleanedText` → `text`.
* **`isGreaterThan`, `isLowerThan`, `isGreaterOrEqualsThan`, `isLowerOrEqualsThan`** — Lógica invertida corrigida: agora notificam quando a condição **falha**, não quando é verdadeira.
* **`areEquals`** — Corrigido para notificar quando os valores são **diferentes**.
* **`areNotEquals`** — Corrigido para notificar quando os valores são **iguais**.
* **`isBetween`** — Corrigido para notificar quando o valor está **fora** do intervalo.
* **`all_validations_br.dart`** — Corrigido casing do path `Notifications` (causava erro em Linux/CI).

---

## 3.2.3
### 🆕 Novas Funcionalidades
* **Validação de Código de Barras (EAN-13)**
  - `isValidEAN13`: Valida se um código de barras EAN-13 é válido, garantindo conformidade com o padrão oficial.

* **Validação de Cores Hexadecimais**
  - `isValidHexColor`: Verifica se uma string representa uma cor em formato hexadecimal válido.

* **Contagem de Palavras**
  - `countWords`: Conta o número de palavras em uma string, útil para análise de textos e validações de preenchimento.

* **Geração de UUIDs**
  - `generateUUIDv3`: Gera um UUID versão 3 baseado em namespace e nome usando MD5.
  - `generateUUIDv4`: Gera um UUID versão 4 aleatório.
  - `generateUUIDv5`: Gera um UUID versão 5 baseado em namespace e nome usando SHA-1.

---

## 3.2.2
###  Novas Funcionalidades
* **Remoção de Tags HTML**
  - `removeHtmlTags`: Remove todas as tags HTML de um texto, retornando apenas o conteúdo limpo. Método robusto e performático para sanitização de entradas.

---

## 3.2.0
###  Novas Funcionalidades
* **Criptografia e Validação de Senhas**
  - `encryptPassword`: Gera uma senha criptografada utilizando uma chave de segurança personalizada.
  - `validatePassword`: Valida se uma senha corresponde ao hash gerado.

* **Utilidades Adicionais**
  - `formatCurrency`: Formata números para o padrão de moeda brasileiro (`R$`).
  - `calculatePercentage`: Calcula a porcentagem de um valor em relação a um total.
  - `generateRandomString`: Gera strings aleatórias de tamanho personalizado.

* **Manipulações de Texto**
  - `capitalizeWords`: Converte a primeira letra de cada palavra para maiúscula.
  - `removeNonNumeric`: Remove todos os caracteres não numéricos de uma string.

* **Utilidades de Datas**
  - `businessDaysBetween`: Calcula o número de dias úteis entre duas datas.
  - `daysBetween`: Calcula a diferença em dias entre duas datas.

---

## 3.1.2
### 🔧 Melhorias e Novas Funcionalidades
* Atualização para Contratos:
  - `isStrongPassword`: Verifica a força de uma senha.
  - `isURL`: Valida URLs.
  - `isPhoneNumber`: Valida números de telefone brasileiro (celulares e fixos).
  - `isValidBRZip`: Verifica o formato de CEP brasileiro.
  - `isUUID`: Valida identificadores únicos (UUID).
  - `isPalindrome`: Verifica se uma string é um palíndromo.
  - `customValidation`: Permite validações customizadas.
  - `isEnum`: Verifica se um valor pertence a um enum.
  - `isBefore`: Valida se uma data é anterior a outra.
  - `isUnique`: Valida se um valor é único em uma lista.
  - Validações para CPF, CNPJ, tamanhos mínimos/máximos de strings, entre outros.

---

## 3.1.0
### 🛠 Alterações e Melhorias
* **Novo Método**
  - `getStateByDDD`: Retorna o estado brasileiro com base no DDD.
* Suporte para validação de telefones fixos brasileiros com DDD.
* **Breaking Change**: Método `isPhoneNumber` removido. Substitua por:
  - `isBrazilianCellPhone` ou `isBrazilianLandline` para validações específicas.
* Documentação aprimorada e novos testes unitários.

---

## 3.0.0
* Introdução de contratos para validação.
* Alteração em rotas de importação (**Breaking Change**).
* Documentação expandida.

---

## 2.2.1
* Correção de bugs e melhorias em validações como:
  - `isValidBRZip` (por **@lucascorrea30**).
* Novos testes unitários.

---

## 2.2.0
* **Novos Métodos**
  - `isName` por **@lucascorrea30**.

---

## 2.1.0
* Adicionados métodos:
  - `isMediumPassword`, `isStrongPassword`.
  - `isNickname` (por **@danieldcastro**).
  - `removeAccents`, `isPalindrome`.

---

## 2.0.0
* Atualização de SDK.

---

## 1.1.4
* Correções de bugs.

---

## 1.1.2
* Novas validações:
  - `isPDF`, `isTxt`, `isChm`, `isVector`, `isHTML`.

---

## 1.1.0
* Renomeação de métodos:
  - `removeCaracteres` para `removeCharacters` (**Breaking Change**).
* Adicionado método: `isRG`.

---

## 1.0.1
* Primeiras melhorias e novos métodos.

---

## 1.0.0
* Lançamento inicial.
