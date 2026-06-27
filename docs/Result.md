# Result\<F, S\> — Programação Orientada a Trilhos

`Result<F, S>` é um tipo que representa o resultado de uma operação que pode falhar. Em vez de lançar exceções ou retornar `null`, você devolve `Success(valor)` ou `Failure(erro)` — e encadeia as transformações de forma segura.

> Inspirado no `Result` de Rust, Swift e Kotlin Arrow.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

O tipo possui dois subtipos concretos:
- `Failure<F, S>` — carrega o valor de erro (`value`)
- `Success<F, S>` — carrega o valor de sucesso (`value`)

---

## Criando um Result

### `Result.success` / `Result.failure`

```dart
Result<String, int> ok  = Result.success(42);
Result<String, int> err = Result.failure('valor inválido');
```

### `Result.cond` — baseado em condição

```dart
Result<String, String> r = Result.cond(
  cpf.length == 11,
  cpf,              // Success se true
  'CPF inválido',   // Failure se false
);
```

### `Result.condLazy` — valores avaliados preguiçosamente

```dart
Result<String, List<int>> r = Result.condLazy(
  rows.isNotEmpty,
  () => rows,                  // só chamado se true
  () => 'Nenhum resultado',    // só chamado se false
);
```

### `Result.guard` — captura exceções síncronas

```dart
final r = Result.guard(
  () => jsonDecode(raw),
  onError: (e) => 'JSON inválido: $e',
);
// r é Success(decoded) ou Failure('JSON inválido: ...')
```

### `Result.guardTyped` — captura apenas um tipo específico de exceção

```dart
final r = Result.guardTyped<FormatException, String, int>(
  () => int.parse(input),
  onError: (e) => 'Formato inválido: ${e.message}',
);
// Exceções que não são FormatException propagam normalmente
```

### `Result.tryAsync` — operações assíncronas

```dart
final result = await Result.tryAsync<String, Response>(
  () => http.get(Uri.parse('https://api.exemplo.com/cpf/$cpf')),
  onError: (e, stack) => 'Requisição falhou: $e',
);
```

### `Result.tryAsyncTyped` — async com tipo de exceção específico

```dart
final result = await Result.tryAsyncTyped<DioException, String, Response>(
  () => dio.get('/user/$id'),
  onError: (e, _) => 'HTTP ${e.response?.statusCode}',
);
```

---

## Verificando o estado

```dart
result.isSuccess;  // bool — true se Success
result.isFailure;  // bool — true se Failure

// Acesso direto ao valor (cuidado: lança StateError se o lado errado)
result.successValue;  // S — lança StateError em Failure
result.failureValue;  // F — lança StateError em Success
```

> Prefira `fold` ou `getOrElse` para acesso seguro.

---

## Transformações síncronas

### `map` — transforma o Success

```dart
final result = Result.success<String, int>(5)
    .map((n) => n * 2)           // Success(10)
    .map((n) => 'Valor: $n');    // Success('Valor: 10')

// Em Failure, map não executa — o erro propaga
Result.failure<String, int>('err').map((n) => n * 2); // Failure('err')
```

### `mapFailure` — transforma o Failure

```dart
Result.failure<int, String>(404)
    .mapFailure((code) => 'Erro HTTP $code');
// Failure('Erro HTTP 404')
```

### `then` — flatMap/railway (próxima operação pode falhar)

```dart
Result<String, String> validarCpf(String cpf) { ... }
Result<String, User>   buscarUsuario(String cpf) { ... }

final result = validarCpf('529.982.247-25')
    .then((cpf) => buscarUsuario(cpf))
    .map((user) => 'Olá, ${user.nome}');
// Se qualquer etapa falhar, o Failure se propaga — etapas seguintes não executam
```

### `thenFailure` — flatMap do lado Failure

```dart
Result.failure<String, int>('conexão falhou')
    .thenFailure((err) => Result.failure('$err (retry?)'));
```

### `either` — transforma ambos os lados (bimap)

```dart
final normalizado = result.either(
  (err)   => 'ERRO: $err',
  (value) => value.toString(),
);
// retorna Result<String, String> em qualquer caso
```

### `swap` — inverte Success ↔ Failure

```dart
Result.success<String, int>(42).swap();   // Failure(42)
Result.failure<String, int>('x').swap();  // Success('x')
```

---

## Extração segura do valor

```dart
result.fold(
  (err)   => 'Falha: $err',
  (valor) => 'Ok: $valor',
);

result.getOrElse(0);              // valor ou default
result.getOrCall((err) => -1);    // valor ou resultado de fn
result.toNullable();              // valor ou null
result.recover((err) => 0);      // converte Failure em Success
```

---

## Side-effects (sem alterar o Result)

```dart
result
  .tap((v) => log('Sucesso: $v'))             // executa se Success
  .tapFailure((e) => log('Erro: $e'));         // executa se Failure
// ambos retornam o mesmo Result sem alterar nada
```

---

## Encadeamento com `Future<Result<F, S>>`

As extensões em `Future<Result<F, S>>` (arquivo `future_result.dart`) permitem encadear operações async sem `await` intermediários:

### Extensões síncronas em `Result` para uso com async

```dart
// mapAsync — transforma Success de forma assíncrona
final result = await Result.success(42)
    .mapAsync((n) async => await fetchName(n));

// thenAsync — flatMap assíncrono
final result = await Result.success(userId)
    .thenAsync((id) => Result.tryAsync(
          () => api.getUser(id),
          onError: (e, _) => 'Erro de rede',
        ));
```

### Chain completo com `Future<Result>`

```dart
// tryAsync retorna Future<Result<F,S>> — use as extensões FutureResult
final mensagem = await Result.tryAsync<String, String>(
  () => http.read(Uri.parse('https://api.exemplo.com/cpf/$cpf')),
  onError: (e, _) => 'Falha na requisição',
)
.thenAsync((raw) => Result.guard(
      () => jsonDecode(raw) as Map<String, dynamic>,
      onError: (_) => 'JSON inválido',
    ))
.foldAsync(
  (erro)  async => 'Erro: $erro',
  (json)  async => 'CPF: ${json['cpf']}',
);
```

### Tabela completa — `FutureResult` extension em `Future<Result<F, S>>`

| Método | Descrição |
|--------|-----------|
| `isSuccess` | `Future<bool>` — true se Success |
| `isFailure` | `Future<bool>` — true se Failure |
| `mapAsync(fn)` | Transforma o Success de forma async |
| `mapFailureAsync(fn)` | Transforma o Failure de forma async |
| `thenAsync(fn)` | Flatmap async — próxima operação pode falhar |
| `thenFailureAsync(fn)` | Flatmap async do lado Failure |
| `foldAsync(onF, onS)` | Colapsa ambos os lados em async |
| `eitherAsync(onF, onS)` | Transforma ambos os lados de forma async |
| `swap()` | Inverte Success ↔ Failure |
| `recoverAsync(fn)` | Converte Failure em Success de forma async |
| `tapAsync(fn)` | Side-effect no Success (async, sem alterar o valor) |
| `tapFailureAsync(fn)` | Side-effect no Failure (async, sem alterar o erro) |
| `getOrElse(default)` | `Future<S>` — valor ou default |
| `getOrCall(fn)` | `Future<S>` — valor ou resultado de fn |
| `toNullable()` | `Future<S?>` — valor ou null |

---

## Tipos de erro

### `ValidationError` — usado por `AllValidations.validate*()`

```dart
class ValidationError {
  final String property;  // campo que falhou, ex: 'cpf'
  final String message;   // descrição legível, ex: 'CPF inválido.'
}
```

```dart
AllValidations.validateCPF('000.000.000-00').fold(
  (err) => print('${err.property}: ${err.message}'),
  // 'cpf: CPF inválido.'
  (cpf) => print('CPF ok: $cpf'),
);
```

### `ValidationNotification` — usado por `Contract.toResult()`

```dart
class ValidationNotification {
  final String property;
  final String message;
  Map<String, dynamic> toMap(); // {'property': ..., 'message': ...}
}
```

> `ValidationError` e `ValidationNotification` têm a mesma forma (`property` + `message`), mas são tipos distintos. `AllValidations.validate*()` retorna o primeiro; `Contract.toResult()` retorna uma lista do segundo.

### `ValidationResult<T>` — typedef de domínio

```dart
// Equivale a Result<List<ValidationNotification>, T>
ValidationResult<UserDto> result = Contract()
    .requires()
    .isEmail(email, 'email', 'E-mail inválido')
    .toResult(UserDto(...));
```

---

## Contract — validações acumuladas

`Contract` acumula notificações via encadeamento fluente e converte para `Result` ao final. Ideal quando há múltiplos campos a validar e você quer reportar todos os erros de uma vez.

```dart
final result = Contract()
    .requires()
    .isValidCPF(cpf,   'cpf',   'CPF inválido')
    .isEmail(email,    'email', 'E-mail inválido')
    .hasMinLen(nome,   3, 'nome', 'Nome deve ter no mínimo 3 caracteres')
    .toResult(UserDto(cpf: cpf, email: email, nome: nome));

result.fold(
  (erros) => erros.forEach((e) => print('${e.property}: ${e.message}')),
  (user)  => salvarUsuario(user),
);
```

### `toResult` / `toResultFirst` / `toResultAsync`

```dart
// Retorna todos os erros em caso de falha
Result<List<ValidationNotification>, T> toResult<T>(T value)

// Retorna apenas o primeiro erro — útil para formulário por campo
Result<ValidationNotification, T> toResultFirst<T>(T value)

// Versão async — valueFn só é chamada se o contrato for válido
Future<Result<List<ValidationNotification>, T>> toResultAsync<T>(
    Future<T> Function() valueFn)
```

```dart
// toResultFirst — mostrar um snackbar por vez
contract
  .isValidCPF(cpf, 'cpf', 'CPF inválido')
  .isEmail(email, 'email', 'E-mail inválido')
  .toResultFirst(dto)
  .fold(
    (err) => showSnackbar(err.message),
    (dto) => save(dto),
  );

// toResultAsync — buscar dados só se a validação passar
final result = await contract
    .isValidCPF(cpf, 'cpf', 'CPF inválido')
    .toResultAsync(() async => await buscarUsuario(cpf));
```

### Métodos de validação do `Contract`

Todos retornam `Contract` para encadeamento. Adicionam uma `ValidationNotification` se a condição falhar.

**Strings e comprimento:**

| Método | Adiciona notificação se... |
|--------|---------------------------|
| `isNullOrEmpty(val, prop, msg)` | `val` for vazio |
| `isNotNullOrEmpty(val, prop, msg)` | `val` for null ou vazio |
| `isNullOrNullable(val, prop, msg)` | `val` for null |
| `hasMinLen(val, min, prop, msg)` | `val.length < min` |
| `hasMaxLen(val, max, prop, msg)` | `val.length > max` |
| `hasLen(val, len, prop, msg)` | `val.length != len` |
| `hasMinLengthIfNotNullOrEmpty(val, min, prop, msg)` | não vazio e `length < min` |
| `hasMaxLengthIfNotNullOrEmpty(val, max, prop, msg)` | não vazio e `length > max` |
| `hasExactLengthIfNotNullOrEmpty(val, len, prop, msg)` | não vazio e `length != len` |
| `contains(val, text, prop, msg)` | `val` não contiver `text` |
| `isDigit(text, prop, msg)` | `text` não for só dígitos |

**Booleanos e comparação:**

| Método | Adiciona notificação se... |
|--------|---------------------------|
| `isTrue(value, prop, msg)` | `value` for `false` |
| `isFalse(value, prop, msg)` | `value` for `true` |
| `areEquals(a, b, prop, msg)` | `a != b` |
| `areNotEquals(a, b, prop, msg)` | `a == b` |
| `isGreaterThan(val, cmp, prop, msg)` | `val <= cmp` |
| `isGreaterOrEqualsThan(val, cmp, prop, msg)` | `val < cmp` |
| `isLowerThan(val, cmp, prop, msg)` | `val >= cmp` |
| `isLowerOrEqualsThan(val, cmp, prop, msg)` | `val > cmp` |
| `isBetween(val, from, to, prop, msg)` | `val` fora de `[from, to]` |
| `isBefore(start, end, prop, msg)` | `start` não for antes de `end` |

> Todos os métodos de comparação aceitam `DateTime` — a lógica adapta automaticamente para datas.

**Documentos e formatos:**

| Método | Valida |
|--------|--------|
| `isEmail(email, prop, msg)` | e-mail (via `AllValidations.isEmail`) |
| `isValidCPF(cpf, prop, msg)` | CPF (via `AllValidations.isCpf`) |
| `isValidCNPJ(cnpj, prop, msg)` | CNPJ numérico (via `AllValidations.isCnpj`) |
| `isPhoneNumber(phone, prop, msg)` | celular ou fixo brasileiro |
| `isValidBRZip(zip, prop, msg)` | CEP no formato `XXXXX-XXX` |
| `isUUID(value, prop, msg)` | UUID qualquer versão |
| `isStrongPassword(password, prop, msg)` | senha forte (8+ chars, maiúscula, minúscula, dígito, símbolo) |
| `isPalindrome(value, prop, msg)` | string é palíndromo |
| `isURL(url, prop, msg)` | URL com protocolo http/https/ftp |
| `isUnique(value, list, prop, msg)` | `value` NÃO está em `list` |
| `isEnum<T>(value, enumValues, prop, msg)` | `value` está em `enumValues` |

**Customização:**

```dart
contract.customValidation(
  () => cpf.startsWith('0'),
  'cpf',
  'CPF não pode começar com zero',
);

contract.addCustomValidation(
  () => someBusinessRule(),
  'campo',
  'Regra de negócio violada',
);
```

### Métodos utilitários do `Contract`

```dart
// Junta notificações de outros objetos validáveis
contract.join([enderecoContract, pagamentoContract]);

// Mescla notificações de outro Contract
contract.merge(outroContract);

// Para na primeira falha do batch
contract.checkAll(
  [() => cpf.isNotEmpty, () => cpf.length == 11],
  'cpf',
  'CPF inválido',
);

// Adiciona todas as falhas do batch
contract.checkAllStrict(
  [() => nome.isNotEmpty, () => nome.length > 2],
  'nome',
  'Nome inválido',
);

// Adiciona notificação sem condição (erro fixo)
contract.addNotification('campo', 'mensagem de erro');

// Limpa todas as notificações
contract.clearNotifications();

// String com todas as mensagens concatenadas
contract.allMessages; // 'CPF inválido, E-mail inválido'

// Serializa para JSON
contract.toJson();
// {'isValid': false, 'notifications': [{'property': 'cpf', 'message': '...'}]}
```

---

## `AllValidations.validate*()` — validações pontuais com Result

Para validar um campo isolado sem precisar de `Contract`:

```dart
AllValidations.validateCPF('529.982.247-25');
// Success('52998224725')  — dígitos normalizados

AllValidations.validateEmail('Carlos@Exemplo.COM');
// Success('carlos@exemplo.com')  — lowercase + trim

AllValidations.validateCPF('000.000.000-00');
// Failure(ValidationError(property: 'cpf', message: 'CPF inválido.'))

// Property e message customizáveis
AllValidations.validateCPF('invalido',
  property: 'documento',
  message: 'Documento inválido',
);
```

Veja a lista completa em [AllValidations.md](AllValidations.md#validate--validações-com-result).

---

## Referência rápida

| Método | Tipo | Descrição |
|--------|------|-----------|
| `Result.success(v)` | static | Cria Success |
| `Result.failure(e)` | static | Cria Failure |
| `Result.cond(test, s, f)` | static | Condição simples |
| `Result.condLazy(test, s, f)` | static | Condição lazy |
| `Result.guard(fn, {onError})` | static | Captura exceção síncrona |
| `Result.guardTyped<E,...>(fn, {onError})` | static | Captura tipo específico |
| `Result.tryAsync(fn, {onError})` | static | Future com captura |
| `Result.tryAsyncTyped<E,...>(fn, {onError})` | static | Future com tipo específico |
| `isSuccess` / `isFailure` | getter | Estado do Result |
| `successValue` / `failureValue` | getter | Valor (lança StateError no lado errado) |
| `fold(onF, onS)` | método | Consome ambos os lados |
| `map(fn)` | método | Transforma Success |
| `mapFailure(fn)` | método | Transforma Failure |
| `then(fn)` | método | Flatmap — Success pode falhar |
| `thenFailure(fn)` | método | Flatmap — Failure pode virar Success |
| `either(onF, onS)` | método | Bimap |
| `swap()` | método | Inverte lados |
| `getOrElse(d)` | método | Valor ou default |
| `getOrCall(fn)` | método | Valor ou resultado de fn |
| `toNullable()` | método | Valor ou null |
| `tap(fn)` | método | Side-effect em Success |
| `tapFailure(fn)` | método | Side-effect em Failure |
| `recover(fn)` | método | Failure → Success |
| `mapAsync(fn)` | ext | Async — transforma Success |
| `thenAsync(fn)` | ext | Async — flatMap Success |
| `foldAsync(onF, onS)` | ext (`Future<Result>`) | Async — consome ambos |

---

← [Voltar ao README](../README.md)
