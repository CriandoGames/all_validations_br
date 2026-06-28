<h1 align="center">All Validations BR</h1>

<p align="center">
  💡 Validações brasileiras, utilitários e criptografia autenticada — tudo em uma única biblioteca Dart/Flutter, sem dependências externas.
</p>

<p align="center">
  <a href="https://pub.dev/packages/all_validations_br"><img src="https://img.shields.io/pub/v/all_validations_br.svg?label=pub.dev" alt="pub version"></a>
  <a href="https://pub.dev/packages/all_validations_br/score"><img src="https://img.shields.io/pub/likes/all_validations_br?label=likes" alt="pub likes"></a>
  <a href="https://pub.dev/packages/all_validations_br/score"><img src="https://img.shields.io/pub/points/all_validations_br?label=pub%20points" alt="pub points"></a>
  <a href="https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE"><img src="https://img.shields.io/github/license/CriandoGames/all_validations_br" alt="license"></a>
</p>

---

## 🚀 Descrição do Projeto

**AllValidations BR** é uma biblioteca Dart/Flutter com três pilares:

- **Validações brasileiras** — CPF, CNPJ, CNH, RENAVAM, PIS/PASEP, Título de Eleitor, chaves PIX, telefones, CEP, placas, EAN-13 e muito mais.
- **Utilitários** — formatação de moeda, datas, texto, JWT, UUID v3/v4/v5, HTML, PIX e informações de dispositivo.
- **Criptografia autenticada** — implementação Dart pura de ChaCha20-Poly1305 (RFC 8439), com geração segura de chaves, serialização em base64 e detecção automática de adulteração.

---

## 📦 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  all_validations_br: ^4.0.4
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
| **Máscaras de Campo — BrInputMask** | 12 `TextField`s ao vivo: CPF, CNPJ, CNPJ Alfa, CPF/CNPJ dinâmico, Telefone, CEP, Data, Hora, Moeda, Cartão, Validade, Placa |
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
### Classes especializadas

As classes abaixo têm seção dedicada com exemplos completos mais adiante neste documento:

| Classe | O que faz | Docs detalhados |
|--------|----------|----------------|
| [`BrFormatter`](#brformatter--formatação-e-geração-de-documentos-br) | Formata, limpa e gera CPF, CNPJ, CEP, telefone, moeda e KM | [📄 BrFormatter.md](doc/BrFormatter.md) |
| [`BrData`](#brdata--datas-e-horas-sem-intl) | Formato `DD/MM/AAAA` sem `intl` — parse, formatação e validação | [📄 BrData.md](doc/BrData.md) |
| [`BrInputMask`](#máscaras-de-campo--brinputmask) | 19 `TextInputFormatter` com `const` constructor | [📄 BrInputMask.md](doc/BrInputMask.md) |
| [`CnpjAlfanumerico`](#cnpj-alfanumérico-2026--cnpjalfanumerico) | Novo CNPJ com letras — IN RFB 2229/2024 (jul/2026) | [📄 CnpjAlfanumerico.md](doc/CnpjAlfanumerico.md) |
| [`CryptUtil`](#-criptografia-autenticada--cryptutil) | ChaCha20-Poly1305 (RFC 8439) em Dart puro | [📄 CryptUtil.md](doc/CryptUtil.md) |
| [`Result<F, S>`](#-result--programação-orientada-a-trilhos) | Tipo funcional Success/Failure com railway operators | [📄 Result.md](doc/Result.md) |
| [`Contract`](#integração-com-contract) | Contratos de validação com notificações de erro detalhadas | [📄 Result.md#integração-com-contract](doc/Result.md#integração-com-contract) |

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

### Função para Retornar o Estado pelo DDD

```dart
print(AllValidations.getStateByDDD("11")); 
// Saída: BrazilianState.SP
```

---

## 🔒 Criptografia Autenticada — CryptUtil

`CryptUtil` implementa **ChaCha20-Poly1305** (RFC 8439) em Dart puro, sem dependências externas. O algoritmo é AEAD (_Authenticated Encryption with Associated Data_): garante **confidencialidade** e **integridade** em uma única operação. Qualquer adulteração nos dados — seja no ciphertext, na tag ou no nonce — é detectada automaticamente.

### Uso básico — texto

```dart
import 'package:all_validations_br/all_validations_br.dart';

// 1. Gera uma chave de 32 bytes (guarde em armazenamento seguro)
final key = CryptUtil.generateKey();

// 2. Criptografa
final payload = CryptUtil.encryptText('Dados sensíveis', key: key);

// 3. Decriptografa
final texto = CryptUtil.decryptText(payload);
print(texto); // 'Dados sensíveis'
```

### Uso básico — bytes

```dart
final data = [1, 2, 3, 4, 5];
final key  = CryptUtil.generateKey();

final payload      = CryptUtil.encryptBytes(data, key: key);
final List<int> restored = CryptUtil.decryptBytes(payload);
```

### Serialização (armazenamento / transmissão)

O `EncryptedPayload` pode ser serializado para JSON ou para uma string base64 compacta.

```dart
// Serializa como string base64 (ideal para SharedPreferences, banco, API)
final encoded = CryptUtil.encryptToBase64('secreto', key: key);

// Restaura e decriptografa
final original = CryptUtil.decryptFromBase64(encoded);

// Ou via JSON
final json    = payload.toJson();          // Map<String, dynamic>
final payload2 = EncryptedPayload.fromJson(json);
```

### Com AAD (Additional Authenticated Data)

AAD é autenticado mas **não cifrado** — útil para vincular metadados ao ciphertext.
Se o AAD for alterado na decriptação, um `CryptException` é lançado.

```dart
import 'dart:convert';

final aad     = utf8.encode('user_id:42');
final payload = CryptUtil.encryptText('dado privado', key: key, aad: aad);

// Decriptografa normalmente (AAD está no payload)
final texto = CryptUtil.decryptText(payload);
```

### Detecção de adulteração

```dart
try {
  final texto = CryptUtil.decryptText(payload);
} on CryptException catch (e) {
  // Dados corrompidos ou chave/nonce incorretos
  print(e); // CryptException: Tag de autenticação inválida.
}
```

### Referência da API

| Método | Descrição |
|--------|-----------|
| `CryptUtil.encryptText(text, {key?, nonce?, aad?})` | Cifra uma String e retorna `EncryptedPayload` |
| `CryptUtil.decryptText(payload)` | Decifra e retorna a String original |
| `CryptUtil.encryptBytes(bytes, {key?, nonce?, aad?})` | Cifra bytes e retorna `EncryptedPayload` |
| `CryptUtil.decryptBytes(payload)` | Decifra e retorna `List<int>` |
| `CryptUtil.encryptToBase64(text, {key?, nonce?, aad?})` | Cifra e serializa como String base64 |
| `CryptUtil.decryptFromBase64(encoded)` | Deserializa e decifra de String base64 |
| `CryptUtil.generateKey()` | Gera chave de 32 bytes (`Random.secure`) |
| `CryptUtil.generateNonce()` | Gera nonce de 12 bytes (`Random.secure`) |

### Boas práticas

- **Armazene a chave** em `flutter_secure_storage` ou equivalente — nunca em `SharedPreferences` em texto puro.
- **Não reutilize** o mesmo par `(key, nonce)` para dados diferentes. Por padrão, um nonce aleatório é gerado a cada chamada de `encryptText`/`encryptBytes`.
- **Trate `CryptException`** sempre — indica dados adulterados ou chave incorreta.

---

## 🚦 Result — Programação Orientada a Trilhos

`Result<F, S>` é um tipo que representa o resultado de uma operação que pode falhar.
Em vez de lançar exceções ou retornar `null`, você devolve `Success(valor)` ou `Failure(erro)` — e encadeia as transformações de forma segura.

> Inspirado no `Result` de Rust, Swift e Kotlin Arrow — amplamente reconhecido no mercado.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

### Criando um Result

```dart
// Sucesso
Result<String, int> ok = Result.success(42);

// Falha
Result<String, int> err = Result.failure('valor inválido');

// Baseado em condição
Result<String, int> r = Result.cond(cpf.length == 11, cpf, 'CPF deve ter 11 dígitos');

// Capturando exceções de forma funcional
Result<String, int> r = Result.guard(
  () => int.parse(input),
  onError: (e) => 'Não é um número',
);
```

---

### Transformando o valor

```dart
final result = Result.success<String, int>(5)
    .map((n) => n * 2)           // Success(10)
    .map((n) => 'Valor: $n');    // Success('Valor: 10')

// map não executa em Failure — o erro propaga automaticamente
Result.failure<String, int>('err').map((n) => n * 2); // Failure('err')

// mapFailure — transforma o lado do erro
Result.failure<int, String>(404).mapFailure((code) => 'Erro $code');
```

---

### Encadeamento com `.then()` (flatMap / railway)

```dart
Result<String, String> validarCPF(String cpf) { ... }
Result<String, User>   buscarUsuario(String cpf) { ... }

final result = validarCPF('529.982.247-25')
    .then((cpf) => buscarUsuario(cpf))
    .map((user) => 'Olá, ${user.nome}');

// Se qualquer etapa falhar, o Failure se propaga automaticamente
// — nenhuma etapa seguinte é executada.
```

---

### Consumindo o resultado com `.fold()`

```dart
final mensagem = result.fold(
  (erro)  => 'Falha: $erro',    // executado em Failure
  (valor) => 'Ok: $valor',      // executado em Success
);
```

Outros métodos utilitários:

```dart
result.isSuccess;              // bool
result.isFailure;              // bool
result.successValue;           // valor (lança StateError em Failure)
result.failureValue;           // erro  (lança StateError em Success)

result.getOrElse(0);           // valor ou default
result.getOrCall((err) => -1); // valor ou resultado de fn
result.toNullable();           // valor ou null
result.recover((err) => -1);  // converte Failure em Success
result.swap();                 // inverte Success ↔ Failure
```

---

### Operações assíncronas

Envolva chamadas HTTP, banco de dados ou qualquer `Future` que possa falhar:

```dart
final result = await Result.tryAsync<String, User>(
  () => api.getUser(id),
  onError: (e, stack) => 'Falha na requisição: $e',
);
```

Capturando apenas um tipo específico de exceção:

```dart
final result = await Result.tryAsyncTyped<DioException, String, User>(
  () => dio.get('/user/$id'),
  onError: (e, _) => 'HTTP ${e.response?.statusCode}',
);
```

#### Chain completo — exemplo real (HTTP + parse + validação)

```dart
final mensagem = await Result.tryAsync<String, String>(
  () => http.read(Uri.parse('https://api.exemplo.com/cpf/$cpf')),
  onError: (e, _) => 'Falha na requisição',
)
.thenAsync((raw) async => parseJson(raw))
.thenAsync((json) async => AllValidations.validateCPF(json['cpf']))
.foldAsync(
  (erro)  async => 'Erro: ${erro.message}',
  (cpfOk) async => 'CPF válido: $cpfOk',
);
```

Extensões disponíveis em `Future<Result<F, S>>`:

| Método | Descrição |
|--------|-----------|
| `mapAsync(fn)` | Transforma o valor em async |
| `thenAsync(fn)` | Encadeia outro `Future<Result>` |
| `foldAsync(onF, onS)` | Consome ambos os lados em async |
| `recoverAsync(fn)` | Converte Failure em Success em async |
| `tapAsync(fn)` | Side-effect em Success (sem alterar o valor) |
| `tapFailureAsync(fn)` | Side-effect em Failure (sem alterar o erro) |
| `getOrElse(default)` | Valor ou default |
| `toNullable()` | Valor ou null |

---

### Integração com `Contract`

Todos os métodos de validação de `Contract` retornam `ContractValidations` — basta chamar `.toResult()` no final do chain:

```dart
// Retorna todas as notificações de erro em caso de falha
final result = Contract()
    .requires()
    .isValidCPF(cpf, 'cpf', 'CPF inválido')
    .isEmail(email, 'email', 'E-mail inválido')
    .toResult(UserDto(cpf: cpf, email: email));

result.fold(
  (erros) => erros.forEach((e) => print('${e.property}: ${e.message}')),
  (user)  => salvarUsuario(user),
);

// Retorna apenas o primeiro erro
final result = contract.toResultFirst(dto);
result.fold(
  (erro) => showSnackbar(erro.message),
  (dto)  => save(dto),
);

// Versão async — valueFn só é chamada se o contrato for válido
final result = await contract.toResultAsync(() async => await fetchUser(id));
```

`ValidationResult<T>` é um typedef pronto para o caso mais comum:

```dart
// equivale a Result<List<ValidationNotification>, T>
ValidationResult<UserDto> validate(UserDto dto) {
  return Contract()
      .requires()
      .isEmail(dto.email, 'email', 'E-mail inválido')
      .toResult(dto);
}
```

---

### `AllValidations.validate*()` — validações pontuais com Result

Para validar um campo isolado sem precisar de `Contract`:

```dart
// CPF — Success carrega os dígitos normalizados
AllValidations.validateCPF('529.982.247-25');
// Success('52998224725')

// E-mail — Success carrega em lowercase
AllValidations.validateEmail('Carlos@Exemplo.COM');
// Success('carlos@exemplo.com')

// Failure carrega ValidationError com property e message
AllValidations.validateCPF('000.000.000-00');
// Failure(ValidationError(property: 'cpf', message: 'CPF inválido.'))

// Customizando property/message
AllValidations.validateCPF('invalido', property: 'documento', message: 'Documento inválido');
```

Métodos disponíveis:

| Método | Success carrega |
|--------|----------------|
| `validateCPF(cpf)` | dígitos normalizados |
| `validateCNPJ(cnpj)` | dígitos normalizados |
| `validateEmail(email)` | email em lowercase |
| `validateCEP(cep)` | dígitos normalizados |
| `validateCellPhone(phone)` | valor original |
| `validateLandline(phone)` | valor original |
| `validateCNH(cnh)` | dígitos normalizados |
| `validateRENAVAM(renavam)` | dígitos normalizados |
| `validatePIS(pis)` | dígitos normalizados |
| `validateTituloEleitor(titulo)` | dígitos normalizados |
| `validateRG(rg)` | valor original |
| `validateLicensePlate(plate)` | placa em maiúsculas |
| `validateURL(url)` | valor original |
| `validateUUID(uuid)` | valor original |
| `validateStrongPassword(pass)` | valor original |
| `validateCreditCard(number)` | dígitos normalizados |
| `validatePixKey(key)` | tipo: `'CPF'`, `'Celular'`, `'Email'`, `'Chave Aleatória'` |

---

## Verificação de Chaves em Mapas JSON

```dart
Map<String, dynamic> map1 = {"status": "success", "message": "successfully logged out"};

bool existe = AllValidations.isMapExists(map: map1, key: ['status']);
// Retorna: true
``` 

## Validação de Chaves PIX

`HelperUtil.validatePixKey` identifica o tipo da chave PIX informada, seguindo a ordem de validação definida pelo BACEN:

1. **CPF** — 11 dígitos com dígitos verificadores válidos (aceita formato com ou sem máscara)
2. **Celular** — formato E.164: `+55` + DDD + número começando com `9` (ex: `+5511912345678`)
3. **E-mail** — endereço de e-mail válido
4. **Chave aleatória** — UUID v4 (ex: `123e4567-e89b-4d3a-a456-426614174000`)

> **Otimização:** se o valor contiver apenas dígitos, e-mail e chave aleatória são descartados imediatamente.

```dart
// CPF (com ou sem máscara)
HelperUtil.validatePixKey('992.864.791-74'); // 'CPF'
HelperUtil.validatePixKey('99286479174');    // 'CPF'

// Celular — obrigatório formato E.164
HelperUtil.validatePixKey('+5511912345678'); // 'Celular'

// E-mail
HelperUtil.validatePixKey('user@example.com'); // 'Email'

// Chave aleatória — UUID v4
HelperUtil.validatePixKey('123e4567-e89b-4d3a-a456-426614174000'); // 'Chave Aleatória'

// Inválido
HelperUtil.validatePixKey('12345678901'); // null
```

## Mascaramento de Chave PIX

```dart
HelperUtil.maskPixKey('99286479174');                        // '992.***.***-74'
HelperUtil.maskPixKey('+5511912345678');                     // '+5511*****678'
HelperUtil.maskPixKey('user@example.com');                   // 'us**@example.com'
HelperUtil.maskPixKey('123e4567-e89b-4d3a-a456-426614174000'); // '123e4567-****-****-****-426614174000'
```

## CNPJ Alfanumérico 2026 — `CnpjAlfanumerico`

A partir de julho de 2026, a Receita Federal passa a emitir CNPJs com letras maiúsculas (A–Z) nos 12 primeiros caracteres, conforme a **IN RFB 2229/2024**. Os 2 dígitos verificadores continuam sendo sempre numéricos.

Formato: `AA.BBB.CCC/DDDD-VV`

### Validação

```dart
// Aceita CNPJ numérico legado (retrocompatível)
CnpjAlfanumerico.isValid('11.222.333/0001-81'); // true

// Aceita CNPJ alfanumérico 2026 (com ou sem máscara)
CnpjAlfanumerico.isValid('AB.1CD.2EF/3GHI-45'); // true
CnpjAlfanumerico.isValid('AB1CD2EF3GHI45');      // true (sem máscara)

// Atalho via AllValidations
AllValidations.isCnpjAlphanumeric('AB.1CD.2EF/3GHI-45'); // true
```

### Formatação e strip

```dart
// Aplica a máscara XX.XXX.XXX/XXXX-VV
CnpjAlfanumerico.format('AB1CD2EF3GHI45'); // 'AB.1CD.2EF/3GHI-45'

// Remove a máscara (preserva [A-Z0-9], converte para maiúsculas)
CnpjAlfanumerico.strip('ab.1cd.2ef/3ghi-45'); // 'AB1CD2EF3GHI45'
```

### Geração (útil para testes)

```dart
// CNPJ alfanumérico ou numérico aleatório válido
final cnpj = CnpjAlfanumerico.generate();
// Ex.: 'K7B3X19QAC0234'

// Com máscara
final formatado = CnpjAlfanumerico.generate(formatted: true);
// Ex.: 'K7.B3X.19Q/AC02-34'

// Garante ao menos uma letra nos 12 primeiros caracteres
final alfanumerico = CnpjAlfanumerico.generate(forceAlphanumeric: true);
```


## BrFormatter — formatação e geração de documentos BR

`BrFormatter` é a classe central para formatar, limpar e **gerar** dados tipicamente brasileiros — CPF, CNPJ, CEP, telefone, moeda e quilometragem — sem nenhuma dependência externa.

### CPF

```dart
import 'package:all_validations_br/all_validations_br.dart';

// Gera um CPF válido aleatório
final cpf = BrFormatter.generateCpf();             // '52998224725'
final cpfF = BrFormatter.generateCpf(formatted: true); // '529.982.247-25'

// Formata um CPF já existente
BrFormatter.formatCpf('52998224725'); // '529.982.247-25'

// Remove a máscara
BrFormatter.stripCpf('529.982.247-25'); // '52998224725'
```

### CNPJ numérico

```dart
// Gera um CNPJ numérico válido aleatório
final cnpj = BrFormatter.generateCnpj();              // '11222333000181'
final cnpjF = BrFormatter.generateCnpj(formatted: true); // '11.222.333/0001-81'

// Formata / remove máscara
BrFormatter.formatCnpj('11222333000181'); // '11.222.333/0001-81'
BrFormatter.stripCnpj('11.222.333/0001-81'); // '11222333000181'

// Para CNPJ alfanumérico 2026, use CnpjAlfanumerico:
CnpjAlfanumerico.generate(forceAlphanumeric: true, formatted: true);
```

### CEP e Telefone

```dart
BrFormatter.formatCep('01310100');   // '01310-100'
BrFormatter.stripCep('01310-100');   // '01310100'

BrFormatter.formatPhone('11999998877');            // '(11) 99999-8877'
BrFormatter.formatPhone('1133334444');             // '(11) 3333-4444'
BrFormatter.formatPhone('11999998877', ddd: false); // '99999-8877'
BrFormatter.extractDdd('11999998877');             // '11'
```

### Moeda

```dart
BrFormatter.formatCurrency(1234.56);                    // 'R$ 1.234,56'
BrFormatter.formatCurrency(85437107.04);                // 'R$ 85.437.107,04'
BrFormatter.formatCurrency(1234.56, symbol: false);     // '1.234,56'
BrFormatter.formatCurrency(1234.0,  decimals: 0);       // 'R$ 1.234'

BrFormatter.parseCurrency('R$ 1.234,56');  // 1234.56
BrFormatter.stripCurrencySymbol('R$ 99,90'); // '99,90'
```

### KM

```dart
BrFormatter.formatKm(85437);    // '85.437 km'
BrFormatter.formatKm(1000000);  // '1.000.000 km'
```

---

## Máscaras de Campo — `BrInputMask`

Todas as máscaras estendem `BrInputMask` (que estende `TextInputFormatter`) e possuem `const` constructors — zero custo de instanciação. Basta adicioná-las ao `inputFormatters` do `TextField`.

### CPF, CNPJ e CNPJ Alfanumérico 2026

```dart
import 'package:all_validations_br/all_validations_br.dart';

// CPF → '529.982.247-25'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CpfMask()],
)

// CNPJ numérico → '11.222.333/0001-81'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CnpjMask()],
)

// CNPJ alfanumérico 2026 → 'AB.123.CDE/0001-39'
TextField(
  keyboardType: TextInputType.text,
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [CnpjAlfaMask()],
)
```

### Telefone e CEP

```dart
// Telefone dinâmico: (11) 3333-4444 ou (11) 99999-8877
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [PhoneMask()],
)

// CEP → '01310-100'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CepMask()],
)
```

### Data e Hora

```dart
// Data → '26/06/2026'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [DateMask()],
)

// Hora → '14:30'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [TimeMask()],
)
```

### Moeda

```dart
// Moeda em tempo real → 'R$ 1.234,56'
// Abordagem centavos: '1' → 'R$ 0,01'; '123456' → 'R$ 1.234,56'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CurrencyMask()],
)
```

### Cartão de Crédito

```dart
// Número do cartão → '4111 1111 1111 1111'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CardMask()],
)

// Validade MM/AA  → '12/24'
// Validade MM/AAAA → '12/2024'  (alterna automaticamente a partir do 5° dígito)
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CardExpiryMask()],
)
```

### Quilometragem

```dart
// KM → '999.999' / '9.999.999'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [KmMask()],
)
```

### Centavos (sem prefixo R$)

Variante da `CurrencyMask` sem o símbolo — útil quando `R$` já aparece como label ou prefixo na `InputDecoration`.

```dart
// '1'       → '0,01'
// '7194'    → '71,94'
// '1234567' → '12.345,67'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CentavosMask()],
  decoration: InputDecoration(prefixText: 'R\$ '),
)
```

### NCM

```dart
// NCM → '1234.56.78'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [NcmMask()],
)
```

### CNS — Cartão Nacional de Saúde

```dart
// CNS → '111 2222 3333 4444'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CnsMask()],
)
```

### Medidas — Altura, Peso e Temperatura

```dart
// Altura → '1,75'  (X,XX — máx 3 dígitos)
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [AlturaMask()],
  decoration: InputDecoration(suffixText: 'm'),
)

// Peso → '705,1'  (XXX,X — máx 4 dígitos)
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [PesoMask()],
  decoration: InputDecoration(suffixText: 'kg'),
)

// Temperatura → '36,5'  (XX,X — máx 3 dígitos)
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [TemperaturaMask()],
  decoration: InputDecoration(suffixText: '°C'),
)
```

### CPF ou CNPJ dinâmico

Alterna automaticamente entre CPF e CNPJ conforme o usuário digita — sem necessidade de dois campos separados.

```dart
// ≤ 11 dígitos → '123.456.789-01' (CPF)
// > 11 dígitos → '11.222.333/0001-81' (CNPJ, máx 14)
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CpfOuCnpjMask()],
)
```

### Placa de Veículo

Aceita os dois formatos brasileiros: antigo (`ABC-1234`) e Mercosul (`ABC-1D23`). Converte automaticamente para maiúsculas.

```dart
// Formato antigo  → 'ABC-1234'
// Formato Mercosul → 'ABC-1D23'
TextField(
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [PlacaMask()],
)
```

### Referência rápida

| Classe | Máscara | Chars max |
|--------|---------|-----------|
| `CpfMask` | `999.999.999-99` | 11 |
| `CnpjMask` | `99.999.999/9999-99` | 14 |
| `CnpjAlfaMask` | `AA.BBB.CCC/DDDD-VV` | 14 |
| `CpfOuCnpjMask` | `999.999.999-99` / `99.999.999/9999-99` | 11/14 |
| `PhoneMask` | `(99) 9999-9999` / `(99) 99999-9999` | 10/11 |
| `CepMask` | `99999-999` | 8 |
| `DateMask` | `99/99/9999` | 8 |
| `TimeMask` | `99:99` | 4 |
| `CurrencyMask` | `R$ 9.999,99` | 13 |
| `CardMask` | `9999 9999 9999 9999` | 16 |
| `CardExpiryMask` | `99/99` / `99/9999` | 4/6 |
| `PlacaMask` | `AAA-9999` / `AAA-9A99` | 7 |
| `KmMask` | `9.999.999` | 7 |
| `CentavosMask` | `9.999,99` (sem R$) | 13 |
| `NcmMask` | `1234.56.78` | 8 |
| `CnsMask` | `111 2222 3333 4444` | 15 |
| `AlturaMask` | `X,XX` | 3 |
| `PesoMask` | `XXX,X` | 4 |
| `TemperaturaMask` | `XX,X` | 3 |

---

## BrData — datas e horas sem `intl`

`BrData` oferece formatação, parse e validação de datas no padrão brasileiro (`DD/MM/AAAA`) implementados em Dart puro — sem precisar adicionar o pacote `intl`.

```dart
import 'package:all_validations_br/all_validations_br.dart';

final hoje = DateTime(2026, 7, 1, 9, 5, 3);

// Formatação
BrData.format(hoje);           // '01/07/2026'
BrData.formatMonthYear(hoje);  // '07/2026'
BrData.formatDayMonth(hoje);   // '01/07'
BrData.formatTime(hoje);       // '09:05:03'
BrData.formatTimeShort(hoje);  // '09:05'

// Parse
final dt = BrData.parse('26/06/2026');
// DateTime(2026, 6, 26)

final dtHora = BrData.parseWithTime('26/06/2026 14:30');
// DateTime(2026, 6, 26, 14, 30)

// Validação (inclui anos bissextos e meses com 30/31 dias)
BrData.validate('29/02/2024'); // true  (2024 é bissexto)
BrData.validate('29/02/2023'); // false (2023 não é bissexto)
BrData.validate('31/04/2026'); // false (abril tem 30 dias)
```

---

## Validação de Documentos Brasileiros

```dart
// CNH
AllValidations.isCnh('84718735264'); // true

// RENAVAM (aceita 9 ou 11 dígitos)
AllValidations.isRenavam('95606520941'); // true

// PIS/PASEP
AllValidations.isPisPasep('12345678919'); // true

// Título de Eleitor
AllValidations.isTituloEleitor('006000610949'); // true
```

## TextEditingController com dados pré-formatados

Para inicializar um `TextEditingController` com o texto já formatado, use os métodos de formatação da biblioteca diretamente no atributo `text`:

```dart
import 'package:all_validations_br/all_validations_br.dart';

// CPF → '529.982.247-25'
final cpfController = TextEditingController(
  text: BrFormatter.formatCpf('52998224725'),
);

// CNPJ numérico → '11.222.333/0001-81'
final cnpjController = TextEditingController(
  text: BrFormatter.formatCnpj('11222333000181'),
);

// CNPJ alfanumérico 2026 → 'AB.1CD.2EF/0001-99'
final cnpjAlfaController = TextEditingController(
  text: CnpjAlfanumerico.format('AB1CD2EF000199'),
);

// Celular → '(11) 99999-8877'
final celularController = TextEditingController(
  text: BrFormatter.formatPhone('11999998877'),
);

// CEP → '01310-100'
final cepController = TextEditingController(
  text: BrFormatter.formatCep('01310100'),
);

// Data → '31/12/2024'
final dataController = TextEditingController(
  text: BrData.format(DateTime(2024, 12, 31)),
);

// Moeda → 'R$ 1.234,56'
final valorController = TextEditingController(
  text: BrFormatter.formatCurrency(1234.56),
);
```

---

## Validação de Data e Maioridade

```dart
// Verifica se a data existe de verdade
HelperUtil.isValidDate('31/02/2023'); // false
HelperUtil.isValidDate('15/06/2023'); // true
HelperUtil.isValidDate('2023-06-15'); // true

// Verifica maioridade (padrão 18 anos, customizável)
HelperUtil.isAdult(DateTime(2000, 1, 1));           // true
HelperUtil.isAdult(DateTime(2010, 1, 1));           // false
HelperUtil.isAdult(DateTime(2002, 1, 1), minAge: 21); // false
```

---

## 📖 Documentação e Wiki

Para mais detalhes sobre o uso da biblioteca, acesse nossa [Wiki](https://github.com/CriandoGames/all_validations_br/wiki).

---

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
