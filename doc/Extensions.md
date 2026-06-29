# Extensions — Extensões de tipos nativos

Extensões Dart sobre tipos nativos (`bool?`, `String?`, `List<T>?`) para leituras mais fluentes e null-safe, sem precisar de null-checks manuais ou métodos estáticos.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## BoolExtension

Extensão em `bool?` que diferencia explicitamente `true`, `false` e `null`.

```dart
bool? ativo    = true;
bool? inativo  = false;
bool? indefinido = null;

// isTrue — só retorna true para o valor literal true
ativo.isTrue;      // true
inativo.isTrue;    // false
indefinido.isTrue; // false  ← null não lança exceção

// isFalse — só retorna true para o valor literal false
ativo.isFalse;      // false
inativo.isFalse;    // true
indefinido.isFalse; // false  ← null não lança exceção
```

**Uso em condições:**

```dart
bool? logado = await verificarSessao();

if (logado.isTrue) {
  navegarParaHome();
}

if (logado.isFalse) {
  mostrarTelaDeLogin();
}

// null não entra em nenhum dos dois blocos — comportamento seguro
```

---

## StringExtension

Extensão em `String?` para verificação de nulidade/vazio e truncagem de texto.

### isNullOrEmpty / isNotNullOrEmpty

Verifica nulidade ou string vazia literal. Espaços **não** são considerados vazios.

```dart
String? a = null;
String? b = '';
String? c = '   ';
String? d = 'Carlos';

a.isNullOrEmpty; // true
b.isNullOrEmpty; // true
c.isNullOrEmpty; // false  ← espaços contam como conteúdo
d.isNullOrEmpty; // false

a.isNotNullOrEmpty; // false
d.isNotNullOrEmpty; // true
```

### isNullOrEmptyWithSpace / isNotNullOrEmptyWithSpace

Igual ao anterior, mas aplica `trim()` antes — espaços e quebras de linha são ignorados.

```dart
String? a = null;
String? b = '';
String? c = '   ';
String? d = '\t\n';
String? e = '  Carlos  ';

a.isNullOrEmptyWithSpace; // true
b.isNullOrEmptyWithSpace; // true
c.isNullOrEmptyWithSpace; // true  ← só espaços
d.isNullOrEmptyWithSpace; // true  ← tabs e quebras de linha
e.isNullOrEmptyWithSpace; // false ← tem conteúdo real

e.isNotNullOrEmptyWithSpace; // true
```

**Uso em validação de formulário:**

```dart
String? nome = controller.text;

if (nome.isNullOrEmptyWithSpace) {
  mostrarErro('Nome é obrigatório');
  return;
}
```

### truncate

Trunca a string ao máximo de `maxLength` caracteres, adicionando `'...'` quando necessário.

```dart
'Flutter é incrível'.truncate(7);  // 'Flutter...'
'Dart'.truncate(10);               // 'Dart'        ← já cabe, não altera
'Dart'.truncate(4);                // 'Dart'        ← igual ao limite, não altera
null.truncate(5);                  // null          ← null-safe
```

**Uso em UI:**

```dart
Text(produto.descricao.truncate(40) ?? '');

// Log resumido
log.debug('payload: ${json.truncate(100)}');
```

---

## ListExtension

Extensão em `List<T>?` para verificar se uma lista nullable está vazia.

```dart
List<String>? erros   = null;
List<String>? vazia   = [];
List<String>? comDados = ['CPF inválido', 'E-mail obrigatório'];

erros.isNullOrEmpty;     // true
vazia.isNullOrEmpty;     // true
comDados.isNullOrEmpty;  // false

erros.isNotNullOrEmpty;    // false
comDados.isNotNullOrEmpty; // true
```

**Uso em domínio:**

```dart
// Antes — verboso
if (notifications == null || notifications!.isEmpty) { ... }

// Depois — limpo
if (notifications.isNullOrEmpty) { ... }

// Exibir lista de erros só quando houver algo
if (erros.isNotNullOrEmpty) {
  mostrarErros(erros!);
}
```

---

## Tabela de referência rápida

| Extensão | Tipo | Getter / Método | Retorna `true` quando |
|---|---|---|---|
| `BoolExtension` | `bool?` | `isTrue` | valor é literalmente `true` |
| `BoolExtension` | `bool?` | `isFalse` | valor é literalmente `false` |
| `StringExtension` | `String?` | `isNullOrEmpty` | `null` ou `''` |
| `StringExtension` | `String?` | `isNotNullOrEmpty` | não é `null` nem `''` |
| `StringExtension` | `String?` | `isNullOrEmptyWithSpace` | `null`, `''` ou só espaços |
| `StringExtension` | `String?` | `isNotNullOrEmptyWithSpace` | tem conteúdo real após trim |
| `StringExtension` | `String?` | `truncate(int)` | — retorna `String?` truncada |
| `ListExtension` | `List<T>?` | `isNullOrEmpty` | `null` ou lista vazia |
| `ListExtension` | `List<T>?` | `isNotNullOrEmpty` | não é `null` e tem elementos |
