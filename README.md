<h1 align="center">All Validations BR</h1>

<p align="center">
  💡 Validações brasileiras, utilitários e criptografia autenticada — tudo em uma única biblioteca Dart/Flutter, sem dependências externas.
</p>

<p align="center">
  <a href="https://pub.dev/packages/all_validations_br"><img src="https://img.shields.io/pub/v/all_validations_br.svg?label=pub.dev" alt="pub version"></a>
  <a href="https://pub.dev/packages/all_validations_br/score"><img src="https://img.shields.io/pub/likes/all_validations_br?label=likes" alt="pub likes"></a>
  <a href="https://pub.dev/packages/all_validations_br/score"><img src="https://img.shields.io/pub/points/all_validations_br?label=pub%20points" alt="pub points"></a>
  <a href="https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE"><img src="https://img.shields.io/github/license/CriandoGames/all_validations_br" alt="license"></a>
  <img src="https://img.shields.io/badge/testes-1110-brightgreen" alt="1110 testes">
</p>

---

## 🚀 Descrição do Projeto

**AllValidations BR** é uma biblioteca Dart/Flutter com três pilares:

- **Validações brasileiras** — CPF, CNPJ, CNH, RENAVAM, PIS/PASEP, Título de Eleitor, chaves PIX, telefones, CEP, placas, EAN-13 e muito mais.
- **Utilitários** — formatação de moeda, datas, texto, JWT, UUID v3/v4/v5, HTML, PIX e informações de dispositivo.
- **Criptografia pura Dart** — ChaCha20-Poly1305 (RFC 8439), AES-GCM, AES-CBC e AES-CTR; SHA-256 e HMAC-SHA256. Sem dependências externas, **zero `dart:io`**, compatível com Flutter Web e mobile.

---

## 📦 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  all_validations_br: ^4.4.0
```

Em seguida:

```bash
flutter pub get
```

E importe no seu código:

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## 📱 App de Exemplo

O diretório `example/` contém um app Flutter interativo que demonstra as principais funcionalidades da biblioteca.

Para rodar:

```bash
cd example
flutter pub get
flutter run
```

O app está dividido em seções:

| Seção | O que demonstra |
|-------|-----------------|
| **AllValidations — CPF** | Validação de CPFs válidos, inválidos e formatados |
| **HelperUtil — utilitários gerais** | `countWords`, `removeHtmlTags`, `capitalizeWords`, `BrFormatter.formatCurrency`, `daysBetween`, `generateUUIDv4`, `validatePixKey`, `maskPixKey` |
| **Máscaras de Campo — BrInputMask** | 23 `TextField`s ao vivo: CPF, CNPJ, CNPJ Alfa, CPF/CNPJ, Telefone, CEP, Data, Hora, Moeda, Cartão, Validade, Placa, KM, Centavos, NCM, CNS, Altura, Peso, Temperatura, CEST, IOF, NUP, Certidão de Nascimento |
| **CryptUtil — interativo** | Botão "Encriptar / Decriptar" exibe ciphertext em base64 e o texto recuperado; botão "Simular adulteração" demonstra a detecção de `CryptException` |
| **CryptUtil — estáticos** | Round-trip `encryptText` → `decryptText` com exibição da tag Poly1305 em hex |

---

## ⚙️ Funcionalidades

### Validações — `AllValidations`

- Verificação de tipos e formatos:
  - `isNull`, `isNum`, `isNumericOnly`, `isNumericFloat`
  - `isAlphabetOnly`, `isLowercase`, `isUppercase`
  - `isUUID`, `isJSON`, `isHexadecimal`
  - `isEmail`, `isURL`
- Validações específicas:
  - `isCpf`, `isCnpj`, `isCnpjAlphanumeric` (novo formato 2026), `isRG`, `isValidBRZip`
  - `isBrazilianCellPhone`, `isBrazilianLandline`
  - `isLeapYear`, `isValidBrazilianLicensePlate`
  - Validação de código de barras EAN-13: `isValidEAN13`
  - Validação de cores hexadecimais: `isValidHexColor`
  - Validação de chaves PIX: CPF, e-mail, celular e chave aleatória

---
### **Manipulação de Texto — `AllValidations` · `HelperUtil`**
- **Remoção de caracteres especiais:**
  - `removeCharacters`, `removeNonNumeric`, `removeAccents`
- **Formatação de dados:**
  - CPF: `123.456.789-09`
  - CNPJ: `12.345.678/0001-95`
  - Celular: `(11) 99999-9999`
  - Moeda: `R$ 1.234,56`
  - Data e hora: `01/01/2023`, `12:30:45`
- **Outras manipulações:**
  - Comparação de frases: `isPhraseEqual`
  - Capitalização de palavras: `capitalizeWords`
  
---
### **Utilidades para Datas — `HelperUtil`**
- **Conversões de horário:**
  - UTC para local: `convertUtcToLocal`
  - Local para UTC: `convertLocalToUtc`
- **Cálculos com datas:**
  - Diferença entre duas datas: `daysBetween`
  - Dias úteis entre duas datas: `businessDaysBetween`
  - Cálculo de idade: `calculateAge`

---
### **Funções Avançadas — `HelperUtil`**
- **Validações por Regex:**
  - E-mails, URLs, UUIDs, senhas fortes

- **Geração e manipulação:**
  - Strings aleatórias: `generateRandomString`
  - Números aleatórios: `generateRandomInt`
  - Removedor Tags Html: `removeHtmlTags`

- **Geração de UUID:**  
  - `generateUUIDv3` - Baseado em namespace e nome com MD5  
  - `generateUUIDv4` - UUID gerado aleatoriamente  
  - `generateUUIDv5` - Baseado em namespace e nome com SHA-1

  - **Manipulação de JWT:**  
  - `decodeJWT` - Decodifica um JSON Web Token (JWT) e retorna o payload  
  - `isJwtExpired` - Verifica se o token JWT está expirado  
  - `hasJwtClaim` - Verifica se uma chave específica existe no JWT  
  - `getJwtClaim` - Obtém o valor de uma chave específica no JWT  

- **Informações do dispositivo:**
  - Sistema operacional e versão do Dart: `getDeviceInfo`

---
### Classes especializadas e ## 📚 Documentação

Cada classe tem documentação detalhada com exemplos completos na pasta `doc/`:

| Classe | Principais capabilities | Documentação |
|--------|------------------------|--------------|
| `AllValidations` | CPF, CNPJ, CNH, RG, RENAVAM, PIS, Título Eleitor, CEP, Placa, EAN-13, Cor Hex, PIX, UUID, e-mail, URL + `validate*()` retornando `Result` | [📄 AllValidations.md](doc/AllValidations.md) |
| `HelperUtil` | UUID v3/v4/v5, JWT decode/claims/expiry, PIX validação + máscara, datas, maioridade, strings aleatórias, remoção de HTML | [📄 HelperUtil.md](doc/HelperUtil.md) |
| `BrFormatter` | `formatCpf`, `generateCpf`, `formatCnpj`, `generateCnpj`, `formatPhone`, `extractDdd`, `formatCep`, `formatCurrency`, `parseCurrency`, `formatKm` | [📄 BrFormatter.md](doc/BrFormatter.md) |
| `BrData` | `format`, `formatMonthYear`, `formatDayMonth`, `formatTime`, `parse`, `parseWithTime`, `validate` — tudo sem o pacote `intl` | [📄 BrData.md](doc/BrData.md) |
| `BrInputMask` | CPF, CNPJ, CNPJ Alfa, CPF/CNPJ, Telefone, CEP, Data, Hora, Moeda, Centavos, Cartão, Validade, Placa, KM, NCM, CNS, Altura, Peso, Temperatura | [📄 BrInputMask.md](doc/BrInputMask.md) |
| `CnpjAlfanumerico` | `isValid`, `format`, `strip`, `generate(forceAlphanumeric)` — retrocompatível com CNPJ numérico | [📄 CnpjAlfanumerico.md](doc/CnpjAlfanumerico.md) |
| `CryptUtil` | ChaCha20-Poly1305 · AES-GCM · AES-CBC · AES-CTR · SHA-256 · HMAC-SHA256 — API unificada com `encryptAesGcm`, `encryptAesCbc`, `encryptAesCtr`, `decryptAny`, `generateKey`, AAD, serialização JSON/Base64 | [📄 CryptUtil.md](doc/CryptUtil.md) |
| `Result<F, S>` | `map`, `then`, `fold`, `guard`, `tryAsync`, `thenAsync`, `recover`, `swap` + extensões em `Future<Result>` | [📄 Result.md](doc/Result.md) |
| `Contract` | `isEmail`, `isValidCPF`, `hasMinLen`, `requires` → `.toResult()`, `.toResultFirst()`, `.toResultAsync()` | [📄 Result.md](doc/Result.md#integração-com-contract) |
| `BrLogger` | `trace`, `debug`, `info`, `warning`, `error`, `fatal` — filtros por ambiente, printers coloridos (ANSI), outputs plugáveis, zero deps | [📄 BrLogger.md](doc/BrLogger.md) |
| `BrZod` | Validador fluente/encadeado — `required`, `email`, `cpf`, `cnpj`, `cnh`, `cns`, `password`, `uuid`, `url` e mais 20 métodos. `BrZod.validate()` para Maps. Zero deps. | [📄 BrZod.md](doc/BrZod.md) |
| Extensions | `BoolExtension` · `StringExtension` · `ListExtension` — getters null-safe em tipos nativos: `isTrue`, `isFalse`, `isNullOrEmpty`, `isNotNullOrEmpty`, `isNullOrEmptyWithSpace`, `truncate` | [📄 Extensions.md](doc/Extensions.md) |

---

## 🔐 Criptografia — `CryptUtil`

Implementação **Dart pura** (zero dependências externas). Todos os algoritmos operam sobre [`EncryptedPayload`](doc/CryptUtil.md), que serializa chave, nonce, ciphertext, tag e nome do algoritmo em JSON/Base64. Compatível com Flutter Web, mobile e server.

### Algoritmos disponíveis

| Algoritmo | Tipo | Caso de uso |
|-----------|------|-------------|
| **ChaCha20-Poly1305** (padrão) | AEAD ✅ | Recomendado para a maioria dos casos |
| **AES-256-GCM** | AEAD ✅ | Interoperabilidade com sistemas AES |
| **AES-CBC + PKCS#7** | Cifra ⚠️ | Compatibilidade legada; combine com HMAC-SHA256 |
| **AES-CTR** | Cifra ⚠️ | Streaming; combine com HMAC-SHA256 |
| **SHA-256** | Hash | Digest de dados, integridade |
| **HMAC-SHA256** | MAC | Autenticação de mensagem, assinatura de tokens |

> ⚠️ AES-CBC e AES-CTR **não são autenticados**. Prefira ChaCha20-Poly1305 ou AES-GCM quando precisar de integridade garantida.

### Exemplos rápidos

```dart
import 'package:all_validations_br/all_validations_br.dart';
// ou, para usar só o módulo crypt:
import 'package:all_validations_br/crypt.dart';

// ChaCha20-Poly1305 (padrão — AEAD)
final key     = CryptUtil.generateKey();              // 32 bytes
final payload = CryptUtil.encryptText('segredo', key: key);
final texto   = CryptUtil.decryptText(payload);       // 'segredo'

// AES-256-GCM (AEAD)
final nonce   = CryptUtil.generateNonce();            // 12 bytes
final gcm     = CryptUtil.encryptAesGcm(dados, key: key, nonce: nonce);
final plain   = CryptUtil.decryptAesGcm(gcm);

// AES-CBC + PKCS#7
final iv      = CryptUtil.generateIv();               // 16 bytes
final cbc     = CryptUtil.encryptAesCbc(dados, key: key, iv: iv);
final plain2  = CryptUtil.decryptAesCbc(cbc);

// AES-CTR
final ctr     = CryptUtil.encryptAesCtr(dados, key: key);
final plain3  = CryptUtil.decryptAesCtr(ctr);

// Dispatch automático — decifra qualquer payload pelo campo `algorithm`
final qualquer = CryptUtil.decryptAny(payload);       // funciona com todos os algoritmos

// SHA-256
final digest  = sha256(utf8.encode('mensagem'));       // List<int> com 32 bytes

// HMAC-SHA256
final mac     = hmacSha256(key: key, data: dados);

// Serialização — persista ou transmita o payload
final b64      = payload.toBase64();
final restored = EncryptedPayload.fromBase64(b64);
```

---

## 🧭 Escolhendo o modelo de validação

Esta biblioteca oferece **três abordagens** independentes. Você pode usar qualquer uma — ou combiná-las em partes diferentes do mesmo projeto. Não há resposta errada, mas cada modelo tem seu ponto forte.

### Comparativo rápido

| | `Contract` | `Result<F,S>` | `BrZod` |
|---|---|---|---|
| **Estilo** | Imperativo, acumulativo | Funcional, railway-oriented | Fluente, encadeado |
| **Onde brilha** | Validação de entidades de domínio | Operações que podem falhar (async, I/O) | Campos de formulário Flutter |
| **Retorno** | Lista de notificações (`isValid`) | `Success` ou `Failure` | `String?` (validator do TextFormField) |
| **Validação de Map** | — | via `Contract.toResult()` | `BrZod.validate()` |
| **Locale customizado** | — | — | `BrZod.defaultLocale` / `BrZod(locale:)` |
| **Importação** | `all_validations_br.dart` | `all_validations_br.dart` | `br_zod.dart` |

---

### `Contract` — validação de entidades de domínio

Ideal quando você precisa **acumular vários erros** de uma só vez em uma entidade (model, DTO, value object).

```dart
class CadastroParams extends ValidationNotifiable {
  CadastroParams({required String nome, required String email}) {
    addNotifications(
      Contract()
        .hasMinLen(nome, 2, 'nome', 'Nome deve ter no mínimo 2 caracteres')
        .isEmail(email, 'email', 'E-mail inválido'),
    );
  }
}

final params = CadastroParams(nome: 'J', email: 'ruim');
if (params.isNotValid) {
  params.notifications.forEach((n) => print(n.message));
}
```

**Use quando:** validar objetos de domínio antes de persistir; regras de negócio no construtor; checagem de múltiplas propriedades de uma entidade.

---

### `Result<F, S>` — operações que podem falhar

Ideal para **encadear operações assíncronas** ou tratar erros de I/O sem lançar exceções.

```dart
final result = await Result.tryAsync<String, Response>(
  () => dio.get('/api/usuario/$id'),
  onError: (e, _) => 'Falha na requisição: $e',
);

result.fold(
  (erro)  => log.error(erro),
  (dados) => processar(dados),
);
```

**Use quando:** chamadas HTTP, operações de banco, parsing de JSON, qualquer fluxo onde o caminho de sucesso e de falha têm tratamentos distintos.

---

### `BrZod` — campos de formulário Flutter

Ideal para **`TextFormField.validator`** e validação declarativa de formulários, sem boilerplate.

```dart
import 'package:all_validations_br/br_zod.dart';

// Simples
TextFormField(validator: BrZod().required().email().build)
TextFormField(validator: BrZod().required().cpf().build)
TextFormField(validator: BrZod().optional().cep().build)

// Política de senha configurável
TextFormField(
  validator: BrZod().required()
    .password(policy: PasswordPolicy.medium)
    .build,
)

// Validação de payload (API / Shelf)
final result = BrZod.validate(
  data: body,
  params: {
    'email': BrZod().required().email(),
    'cpf':   BrZod().required().cpf(),
  },
);
if (result.isNotValid) return Response.badRequest(body: result.errors.toString());
```

**Use quando:** formulários Flutter com `TextFormField`; validação rápida de payloads de API; quando quer mensagens de erro em PT-BR prontas sem configuração.

---

### ⚠️ O que não fazer

**Não misture modelos no mesmo campo.** Escolha um e seja consistente dentro do mesmo contexto.

```dart
// ❌ Evite: Contract dentro de um validator de TextFormField
TextFormField(
  validator: (v) {
    final c = Contract().isEmail(v ?? '', 'email', 'inválido');
    return c.isValid ? null : c.notifications.first.message;
  },
)

// ✅ Use BrZod para isso — é o que ele foi feito
TextFormField(validator: BrZod().required().email().build)
```

**Não use `BrZod` para lógica de domínio complexa.** Para invariantes de entidade com múltiplas regras interdependentes, `Contract` é mais adequado.

```dart
// ❌ Evite: lógica de domínio espalhada em validators de campo
final validarIdade = BrZod().custom((v) => calcularIdade(v) >= 18).build;

// ✅ Prefira: regra de negócio no domínio, via Contract ou diretamente
class Pessoa extends ValidationNotifiable {
  Pessoa({required DateTime nascimento}) {
    addNotification(
      'idade', 'Deve ser maior de 18 anos',
      when: calcularIdade(nascimento) < 18,
    );
  }
}
```

**Não use `Result` para substituir validators de formulário.** `Result` é para operações com dois caminhos (sucesso / falha), não para campos que só precisam de uma string de erro.

---

## 🧪 Exemplos de Uso

### Validação de Parâmetros

```dart
class TestParameters extends ValidationNotifiable {
  final String name;
  final String email;

  TestParameters({
    required this.name,
    required this.email,
  }) {
    addNotifications(Contract()
        .hasMinLen(name, 2, 'TestParameters.Name',
            "Nome deve ter no mínimo 2 caracteres!")
        .isEmail(email, "TestParameters.Email", "Email deve ser preenchido!"));
  }
}

void main() {
  final testParameters = TestParameters(email: "exemplo@teste.com", name: "c");

  if (testParameters.isValid) {
    print("Válido");
  } else {
    print("Inválido");
    testParameters.notifications.forEach((f) => print(f.message));
  }
}

````

### Validação de CPF

```dart
var isCpf = AllValidations.isCpf("000.000.000-00"); 
// Retorna false
``` 

### Validação de Cores Hexadecimais
```dart
bool isValidColor = AllValidations.isValidHexColor('#FF5733');
// Retorna: true; 
``` 

### Logging com BrLogger

Importação separada — não interfere no resto da biblioteca:

```dart
import 'package:all_validations_br/br_logger.dart';
```

```dart
final log = BrLogger(tag: 'Auth');

log.trace('iniciando handshake');
log.debug('userId: $id');
log.info('login bem-sucedido');
log.warning('token expira em 5 min');
log.error('falha na requisição', error: e, stackTrace: st);
log.fatal('banco de dados indisponível');
```

Por padrão: tudo aparece em debug, apenas `warning+` em produção. Printers, filtros e outputs são substituíveis. Veja [📄 BrLogger.md](doc/BrLogger.md) para configurações avançadas.

---

### Contagem de Palavras em uma String
```dart
int totalWords = HelperUtil.countWords('Flutter é incrível');
// Retorna: 3
``` 

### Remoção de Tags HTML
```dart
String cleanText = HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>');
// Retorna: Hello World
``` 

### Remoção de Caracteres

```dart
var remover = AllValidations.removeCharacters("000.000.000-00"); 
// Retorna: 00000000000
``` 

### Comparação de Senhas ou Frases

```dart
var comparacao = AllValidations.isPhraseEqual("123456789", "123456789");
// Retorna: true
``` 

### Geração de UUIDs
```dart
String uuid4 = HelperUtil.generateUUIDv4();
// Exemplo de saída: '550e8400-e29b-41d4-a716-446655440000'
``` 

### Lista de Dias da Semana

```dart
var diasDaSemana = AllValidationsGetWeek.listDaysWeekAbvr;
// Retorna: ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo']
``` 

### Remoção de Acentos e Caracteres Especiais

```dart
var texto = AllValidations.removeAccents("áãé");
// Retorna: aae
``` 

### Extensions — tipos nativos null-safe

```dart
// bool?
bool? ativo = true;
ativo.isTrue;   // true
ativo.isFalse;  // false

bool? indefinido = null;
indefinido.isTrue;  // false — null nunca lança exceção
indefinido.isFalse; // false

// String?
String? campo = '   ';
campo.isNullOrEmpty;            // false — espaços contam
campo.isNullOrEmptyWithSpace;   // true  — vazio após trim

String? nome = 'Carlos';
nome.isNotNullOrEmpty;          // true
nome.truncate(3);               // 'Car...'

// List<T>?
List<String>? erros = null;
erros.isNullOrEmpty;    // true
erros.isNotNullOrEmpty; // false
```

---

### Função para Retornar o Estado pelo DDD

```dart
print(AllValidations.getStateByDDD("11")); 
// Saída: BrazilianState.SP
```

### `AllValidationsGetMonth`  
Fornece listas de nomes dos meses do ano para fácil acesso e manipulação.  
- Exemplo de uso: `AllValidationsGetMonth.list` → `[Janeiro, Fevereiro, ...]`  

---

### `AllValidationsGetRegions`  
Retorna as regiões do Brasil, útil para aplicações que necessitam de categorização geográfica.  
- Exemplo de uso: `AllValidationsGetRegions.list` → `[Norte, Nordeste, ...]`  

---

### `AllValidationsGetStates`  
Disponibiliza os estados brasileiros e suas siglas.  
- Exemplo de uso: `AllValidationsGetStates.list` → `[SP, RJ, MG, ...]`  

---

### `AllValidationsGetWeek`  
Fornece listas de dias da semana em formato abreviado, completo, apenas dias úteis e com ordenação a partir do domingo.  
- `AllValidationsGetWeek.listDaysWeek` → `['Segunda-Feira', 'Terça-Feira', ..., 'Domingo']`  
- `AllValidationsGetWeek.listDaysWeekAbvr` → `['Segunda', 'Terça', ..., 'Domingo']`  
- `AllValidationsGetWeek.listWorkDays` → `['Segunda-Feira', ..., 'Sexta-Feira']`  
- `AllValidationsGetWeek.listDaysWeekOrdered` → `['Domingo', 'Segunda', ..., 'Sábado']`  

---

## 👥 Contribuidores

[![Contributors](https://contrib.rocks/image?repo=CriandoGames/all_validations_br)](https://github.com/CriandoGames/all_validations_br/graphs/contributors)

Made with [contrib.rocks](https://contrib.rocks).

Contribuições são bem-vindas! Leia o [CONTRIBUTING.md](CONTRIBUTING.md) para começar.

---

## 📄 Licença

Distribuído sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

---

<p align="center">💻 Desenvolvido com ❤️ para facilitar o desenvolvimento no Flutter.</p>
