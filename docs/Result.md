# Result\<F, S\> — Programação Orientada a Trilhos

`Result<F, S>` é um tipo que representa o resultado de uma operação que pode falhar.
Em vez de lançar exceções ou retornar `null`, você devolve `Success(valor)` ou `Failure(erro)` — e encadeia as transformações de forma segura.

> Inspirado no `Result` de Rust, Swift e Kotlin Arrow — amplamente reconhecido no mercado.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Criando um Result

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

## Transformando o valor

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

## Encadeamento com `.then()` (flatMap / railway)

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

## Consumindo o resultado com `.fold()`

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

## Operações assíncronas

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

### Chain completo — exemplo real (HTTP + parse + validação)

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

### Extensões em `Future<Result<F, S>>`

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

## Integração com `Contract`

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

## `AllValidations.validate*()` — validações pontuais com Result

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

### Métodos disponíveis

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

← [Voltar ao README](../README.md)
