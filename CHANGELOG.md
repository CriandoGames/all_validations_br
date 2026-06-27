# Changelog

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
