# CnpjAlfanumerico — CNPJ Alfanumérico 2026

A partir de julho de 2026, a Receita Federal passa a emitir CNPJs com letras maiúsculas (A–Z) nos 12 primeiros caracteres, conforme a **IN RFB 2229/2024**. Os 2 dígitos verificadores continuam sendo sempre numéricos.

Formato: `AA.BBB.CCC/DDDD-VV`

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Validação

```dart
// Aceita CNPJ numérico legado (retrocompatível)
CnpjAlfanumerico.isValid('11.222.333/0001-81'); // true

// Aceita CNPJ alfanumérico 2026 (com ou sem máscara)
CnpjAlfanumerico.isValid('AB.1CD.2EF/3GHI-45'); // true
CnpjAlfanumerico.isValid('AB1CD2EF3GHI45');      // true (sem máscara)

// Atalho via AllValidations
AllValidations.isCnpjAlphanumeric('AB.1CD.2EF/3GHI-45'); // true
```

---

## Formatação e strip

```dart
// Aplica a máscara XX.XXX.XXX/XXXX-VV
CnpjAlfanumerico.format('AB1CD2EF3GHI45'); // 'AB.1CD.2EF/3GHI-45'

// Remove a máscara (preserva [A-Z0-9], converte para maiúsculas)
CnpjAlfanumerico.strip('ab.1cd.2ef/3ghi-45'); // 'AB1CD2EF3GHI45'
```

---

## Geração (útil para testes)

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

---

## Máscara de campo

```dart
// CNPJ alfanumérico 2026 → 'AB.123.CDE/0001-39'
TextField(
  keyboardType: TextInputType.text,
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [CnpjAlfaMask()],
)
```

---

## TextEditingController com CNPJ pré-formatado

```dart
// CNPJ alfanumérico 2026 → 'AB.1CD.2EF/0001-99'
final cnpjAlfaController = TextEditingController(
  text: CnpjAlfanumerico.format('AB1CD2EF000199'),
);
```

---

← [Voltar ao README](../README.md)
