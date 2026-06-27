# BrData — Datas e Horas sem `intl`

`BrData` oferece formatação, parse e validação de datas no padrão brasileiro (`DD/MM/AAAA`) implementados em Dart puro — sem precisar adicionar o pacote `intl`.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Formatação

```dart
final hoje = DateTime(2026, 7, 1, 9, 5, 3);

BrData.format(hoje);           // '01/07/2026'
BrData.formatMonthYear(hoje);  // '07/2026'
BrData.formatDayMonth(hoje);   // '01/07'
BrData.formatTime(hoje);       // '09:05:03'
BrData.formatTimeShort(hoje);  // '09:05'
```

---

## Parse

```dart
final dt = BrData.parse('26/06/2026');
// DateTime(2026, 6, 26)

final dtHora = BrData.parseWithTime('26/06/2026 14:30');
// DateTime(2026, 6, 26, 14, 30)
```

---

## Validação

Inclui verificação de anos bissextos e meses com 30/31 dias:

```dart
BrData.validate('29/02/2024'); // true  (2024 é bissexto)
BrData.validate('29/02/2023'); // false (2023 não é bissexto)
BrData.validate('31/04/2026'); // false (abril tem 30 dias)
```

---

## Validação de Data e Maioridade

```dart
// Verifica se a data existe de verdade
HelperUtil.isValidDate('31/02/2023'); // false
HelperUtil.isValidDate('15/06/2023'); // true
HelperUtil.isValidDate('2023-06-15'); // true

// Verifica maioridade (padrão 18 anos, customizável)
HelperUtil.isAdult(DateTime(2000, 1, 1));              // true
HelperUtil.isAdult(DateTime(2010, 1, 1));              // false
HelperUtil.isAdult(DateTime(2002, 1, 1), minAge: 21); // false
```

---

## TextEditingController com data pré-formatada

```dart
// Data → '31/12/2024'
final dataController = TextEditingController(
  text: BrData.format(DateTime(2024, 12, 31)),
);
```

---

← [Voltar ao README](../README.md)
