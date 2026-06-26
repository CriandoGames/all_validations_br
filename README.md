<h1 align="center">All Validations BR</h1>

<p align="center">
  💡 Validações brasileiras, utilitários e criptografia autenticada — tudo em uma única biblioteca Dart/Flutter, sem dependências externas.
</p>

---

## 🚀 Descrição do Projeto

**AllValidations BR** é uma biblioteca Dart/Flutter com três pilares:

- **Validações brasileiras** — CPF, CNPJ, CNH, RENAVAM, PIS/PASEP, Título de Eleitor, chaves PIX, telefones, CEP, placas, EAN-13 e muito mais.
- **Utilitários** — formatação de moeda, datas, texto, JWT, UUID v3/v4/v5, HTML, PIX e informações de dispositivo.
- **Criptografia autenticada** — implementação Dart pura de ChaCha20-Poly1305 (RFC 8439), com geração segura de chaves, serialização em base64 e detecção automática de adulteração.

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
| **HelperUtil — utilitários gerais** | `countWords`, `removeHtmlTags`, `capitalizeWords`, `formatCurrency`, `daysBetween`, `generateUUIDv4`, `validatePixKey`, `maskPixKey` |
| **CryptUtil — interativo** | Botão "Encriptar / Decriptar" exibe ciphertext em base64 e o texto recuperado; botão "Simular adulteração" demonstra a detecção de `CryptException` |
| **CryptUtil — estáticos** | Round-trip `encryptText` → `decryptText` com exibição da tag Poly1305 em hex |

---

## ⚙️ Funcionalidades

- **Validações Gerais**
- Verificação de tipos e formatos:
  - `isNull`, `isNum`, `isNumericOnly`, `isNumericFloat`
  - `isAlphabetOnly`, `isLowercase`, `isUppercase`
  - `isUUID`, `isJSON`, `isHexadecimal`
  - `isEmail`, `isURL`
- Validações específicas:
  - `isCpf`, `isCnpj`, `isRG`, `isValidBRZip`
  - `isBrazilianCellPhone`, `isBrazilianLandline`
  - `isLeapYear`, `isValidBrazilianLicensePlate`
  - Validação de código de barras EAN-13: `isValidEAN13`
  - Validação de cores hexadecimais: `isValidHexColor`
  - Validação de chaves PIX: CPF, e-mail, celular e chave aleatória

---
### **Manipulação de Texto**
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
### **Utilidades para Datas**
- **Conversões de horário:**
  - UTC para local: `convertUtcToLocal`
  - Local para UTC: `convertLocalToUtc`
- **Cálculos com datas:**
  - Diferença entre duas datas: `daysBetween`
  - Dias úteis entre duas datas: `businessDaysBetween`
  - Cálculo de idade: `calculateAge`

---
### **Funções Avançadas**
- **Validações por Regex:**
  - E-mails, URLs, UUIDs, senhas fortes

- **Geração e manipulação:**
  - Strings aleatórias: `generateRandomString`
  - Números aleatórios: `generateRandomInt`
  - Formatação de moeda: `formatCurrency`
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

- **Result — Programação Orientada a Trilhos**
  - `Result<F, S>`: tipo funcional Success/Failure sem exceções
  - Encadeamento: `.map()`, `.then()`, `.fold()`, `.recover()`
  - Async: `Result.tryAsync()`, extensão `FutureResult`
  - Integração com `Contract`: `.toResult()`, `.toResultFirst()`, `.toResultAsync()`
  - Validações pontuais: `AllValidations.validateCPF()`, `validateEmail()`, `validatePixKey()`, etc.

- **Criptografia básica (HelperUtil)**
  - Criptografa senhas e realiza validações com as funções `encryptPassword e validatePassword`

- **Criptografia autenticada — ChaCha20-Poly1305 (`CryptUtil`)**
  - Implementação Dart pura do algoritmo AEAD ChaCha20-Poly1305 (RFC 8439)
  - `encryptText` / `decryptText` — cifra e decifra strings UTF-8
  - `encryptBytes` / `decryptBytes` — cifra e decifra dados binários
  - `encryptToBase64` / `decryptFromBase64` — serialização como string única
  - `generateKey` / `generateNonce` — geração segura via `Random.secure`

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

## Validação de CPF

```dart
var isCpf = AllValidations.isCpf("000.000.000-00"); 
// Retorna false
``` 

## Validação de Cores Hexadecimais
```dart
bool isValidColor = AllValidations.isValidHexColor('#FF5733');
// Retorna: true; 
``` 

## Contagem de Palavras em uma String
```dart
int totalWords = HelperUtil.countWords('Flutter é incrível');
// Retorna: 3
``` 

## Remoção de Tags HTML
```dart
String cleanText = HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>');
// Retorna: Hello World
``` 

## Remoção de Caracteres

```dart
var remover = AllValidations.removeCharacters("000.000.000-00"); 
// Retorna: 00000000000
``` 

## Comparação de Senhas ou Frases

```dart
var comparacao = AllValidations.isPhraseEqual("123456789", "123456789");
// Retorna: true
``` 

## Geração de UUIDs
```dart
String uuid4 = HelperUtil.generateUUIDv4();
// Exemplo de saída: '550e8400-e29b-41d4-a716-446655440000'
``` 

## Lista de Dias da Semana

```dart
var diasDaSemana = AllValidationsGetWeek.listDaysWeekAbvr;
// Retorna: ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo']
``` 

## Remoção de Acentos e Caracteres Especiais

```dart
var texto = AllValidations.removeAccents("áãé");
// Retorna: aae
``` 

## Função para Retornar o Estado pelo DDD

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

## 🆘 Classes para Uso

Aqui estão as principais classes disponíveis na biblioteca **AllValidations BR**, juntamente com suas funcionalidades para facilitar a validação e manipulação de dados em seus projetos Flutter.

### `HelperUtil`  
Utilitários diversos para manipulação e formatação de dados, incluindo:  
- Decodificação de JWT  
- Geração de strings e números aleatórios  
- Conversão de datas entre UTC e horário local  
- Formatação de valores para moeda brasileira  
- Remoção de tags HTML de strings  
- Geração de UUIDs (v3, v4 e v5)  
- Criptografia e validação de senhas  
- Validação de chaves PIX (CPF, Celular, E-mail, Chave Aleatória)  

---

### `AllValidations`  
Conjunto de funções para validar diferentes tipos de dados, como:  
- CPF e CNPJ  
- E-mail e URL  
- Telefone brasileiro (fixo e celular)  
- CEP, RG e outras identificações  
- Formatos de data, IP e JSON  

---

### `Contract`  
Classe para gerenciamento de contratos de validação, permitindo a criação de regras flexíveis e reutilizáveis para validar dados com notificações de erro detalhadas.  
- Definição de regras de validação personalizada  
- Verificação de requisitos obrigatórios e condições específicas  
- Emissão de notificações de erro em propriedades inválidas
- Conversão direta para `Result` via `.toResult()`, `.toResultFirst()`, `.toResultAsync()`

---

### `Result<F, S>`  
Tipo funcional para representar o resultado de uma operação que pode falhar, eliminando exceções e `null` do fluxo de negócio.  
- `Result.success(value)` / `Result.failure(error)` — construtores básicos  
- `Result.guard` / `Result.tryAsync` — captura exceções de forma funcional  
- `.map()`, `.then()`, `.fold()`, `.recover()` — transformações encadeadas  
- Extensões async via `FutureResult` para operações HTTP, banco e cache  
- `ValidationResult<T>` — alias para `Result<List<ValidationNotification>, T>`  

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
Fornece listas de dias da semana em formato abreviado e completo.  
- Exemplo de uso: `AllValidationsGetWeek.listDaysWeekAbvr` → `[Seg, Ter, Qua, ...]`  

---

### 🤝 Contribuições
  Encontrou algum problema ou tem sugestões para melhorar a biblioteca?
 Contribua abrindo uma issue no nosso repositório oficial do GitHub!
- 🔗 All Validations BR -  [GitHub](https://github.com/CriandoGames/all_validations_br/)

--- 

### 📦 Instalação
## Adicione a dependência ao seu arquivo pubspec.yaml:

dependencies:
  all_validations_br: 

### 📜 Licença
Este projeto está sob a licença MIT.

---

<p align="center">💻 Desenvolvido com ❤️ para facilitar o desenvolvimento no Flutter.</p> 

