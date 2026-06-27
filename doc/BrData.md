# BrData — Datas e Horas sem `intl`

Formatação, parse e validação de datas no padrão brasileiro (`DD/MM/AAAA`) em Dart puro — sem o pacote `intl`. Todos os métodos operam sobre `DateTime` nativo.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Formatação

Todos os métodos aplicam padding automático de zeros (`1` → `'01'`, `7` → `'07'`).

```dart
final dt = DateTime(2026, 7, 1, 9, 5, 3);

BrData.format(dt);           // '01/07/2026'   (DD/MM/AAAA)
BrData.formatMonthYear(dt);  // '07/2026'      (MM/AAAA)
BrData.formatDayMonth(dt);   // '01/07'        (DD/MM)
BrData.formatTime(dt);       // '09:05:03'     (HH:MM:SS)
BrData.formatTimeShort(dt);  // '09:05'        (HH:MM)
```

Casos de borda com padding:

```dart
BrData.format(DateTime(2026, 1, 5));    // '05/01/2026'
BrData.formatTime(DateTime(2026, 1, 1, 0, 0, 0)); // '00:00:00'
```

---

## Parse

`parse` e `parseWithTime` lançam `FormatException` se a string estiver no formato errado **ou** representar uma data inválida. Use `validate` para verificar antes, ou envolva em `try/catch`.

### `BrData.parse` — `'DD/MM/AAAA'` → `DateTime`

```dart
final dt = BrData.parse('26/06/2026');
// DateTime(2026, 6, 26, 0, 0, 0) — hora zerada

BrData.parse('01/01/2000'); // DateTime(2000, 1, 1)
BrData.parse('29/02/2024'); // DateTime(2024, 2, 29) — bissexto, OK
```

Exemplos que lançam `FormatException`:

```dart
BrData.parse('31/02/2024'); // ❌ fevereiro não tem 31 dias
BrData.parse('29/02/2023'); // ❌ 2023 não é bissexto
BrData.parse('2026-06-26'); // ❌ formato ISO — use HelperUtil.isValidDate para isso
BrData.parse('abc');        // ❌ não numérico
```

### `BrData.parseWithTime` — `'DD/MM/AAAA HH:MM'` → `DateTime`

Aceita apenas `HH:MM` — **segundos não são suportados**.

```dart
final dt = BrData.parseWithTime('26/06/2026 14:30');
// DateTime(2026, 6, 26, 14, 30)

BrData.parseWithTime('01/01/2026 09:05'); // DateTime(2026, 1, 1, 9, 5)
```

Exemplos que lançam `FormatException`:

```dart
BrData.parseWithTime('26/06/2026 14:30:00'); // ❌ segundos não suportados
BrData.parseWithTime('26/06/2026');          // ❌ falta a hora
BrData.parseWithTime('26/06/2026 25:00');    // ❌ hora inválida (int.parse passa, mas hora 25 é aceita pelo DateTime — cuidado)
```

---

## Validação

`validate` retorna `bool` e **nunca lança exceção**. Só aceita o formato `'DD/MM/AAAA'`.

```dart
// Anos bissextos
BrData.validate('29/02/2024'); // true  (2024 é bissexto)
BrData.validate('29/02/2023'); // false (2023 não é bissexto)
BrData.validate('29/02/2000'); // true  (2000 divisível por 400)
BrData.validate('29/02/1900'); // false (1900 divisível por 100, não por 400)

// Meses com 30 dias
BrData.validate('31/04/2026'); // false (abril tem 30 dias)
BrData.validate('31/06/2026'); // false (junho tem 30 dias)
BrData.validate('30/04/2026'); // true

// Formatos não aceitos (retorna false, não lança exceção)
BrData.validate('2026-06-26'); // false — use HelperUtil.isValidDate para ISO
BrData.validate('abc');        // false
BrData.validate('');           // false
```

---

## `validate` vs `parse` — quando usar cada um

| Objetivo | Método | Comportamento em erro |
|----------|--------|-----------------------|
| Verificar se a string é válida | `BrData.validate(s)` | retorna `false` |
| Converter string → DateTime | `BrData.parse(s)` | lança `FormatException` |
| Aceitar também formato ISO `YYYY-MM-DD` | `HelperUtil.isValidDate(s)` | retorna `false` |

**Padrão seguro — validar antes de converter:**

```dart
final input = '29/02/2024';

if (BrData.validate(input)) {
  final dt = BrData.parse(input); // seguro aqui
  print(BrData.format(dt));
} else {
  print('Data inválida');
}
```

**Alternativa com try/catch:**

```dart
try {
  final dt = BrData.parse(input);
  // usar dt...
} on FormatException catch (e) {
  print('Erro: $e');
}
```

---

## Integração com campos de texto

```dart
// TextEditingController com data pré-formatada
final dataController = TextEditingController(
  text: BrData.format(DateTime(2024, 12, 31)), // '31/12/2024'
);

// Validar o que o usuário digitou num DateMask()
final input = dataController.text; // ex: '26/06/2026'
if (BrData.validate(input)) {
  final dt = BrData.parse(input);
  // processar dt...
}
```

---

## Comparação com `HelperUtil` para datas

| Método | Formato aceito | Retorno | Diferencial |
|--------|----------------|---------|-------------|
| `BrData.validate(s)` | `'DD/MM/AAAA'` | `bool` | Foca no padrão BR |
| `BrData.parse(s)` | `'DD/MM/AAAA'` | `DateTime` | Lança `FormatException` |
| `BrData.parseWithTime(s)` | `'DD/MM/AAAA HH:MM'` | `DateTime` | Inclui hora |
| `HelperUtil.isValidDate(s)` | `'DD/MM/AAAA'` ou `'YYYY-MM-DD'` | `bool` | Aceita ISO |
| `HelperUtil.calculateAge(dt)` | `DateTime` | `int` | Idade em anos |
| `HelperUtil.isAdult(dt)` | `DateTime` | `bool` | Maioridade customizável |
| `HelperUtil.daysBetween(a, b)` | `DateTime` | `int` | Dias totais |
| `HelperUtil.businessDaysBetween(a, b)` | `DateTime` | `int` | Dias úteis |

---

## Referência rápida

| Método | Formato | Retorno |
|--------|---------|---------|
| `BrData.format(dt)` | `DD/MM/AAAA` | `String` |
| `BrData.formatMonthYear(dt)` | `MM/AAAA` | `String` |
| `BrData.formatDayMonth(dt)` | `DD/MM` | `String` |
| `BrData.formatTime(dt)` | `HH:MM:SS` | `String` |
| `BrData.formatTimeShort(dt)` | `HH:MM` | `String` |
| `BrData.parse(s)` | `DD/MM/AAAA` → `DateTime` | `DateTime` ¹ |
| `BrData.parseWithTime(s)` | `DD/MM/AAAA HH:MM` → `DateTime` | `DateTime` ¹ |
| `BrData.validate(s)` | `DD/MM/AAAA` | `bool` |

¹ Lança `FormatException` em caso de formato inválido ou data inexistente.

---

← [Voltar ao README](../README.md)
