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
// Exemplo oficial (SERPRO — Cálculo dos DVs de CNPJ alfanumérico):
CnpjAlfanumerico.isValid('12.ABC.345/01DE-35'); // true
CnpjAlfanumerico.isValid('12ABC34501DE35');      // true (sem máscara)

// Atalho via AllValidations
AllValidations.isCnpjAlphanumeric('12.ABC.345/01DE-35'); // true
```

A validação aceita somente os 14 caracteres sem máscara ou a máscara oficial
`AA.BBB.CCC/DDDD-VV`. Prefixos, sufixos e outros separadores são rejeitados.

---

## Formatação e strip

```dart
// Aplica a máscara XX.XXX.XXX/XXXX-VV
CnpjAlfanumerico.format('12ABC34501DE35'); // '12.ABC.345/01DE-35'

// Remove a máscara (preserva [A-Z0-9], converte para maiúsculas)
CnpjAlfanumerico.strip('12.abc.345/01de-35'); // '12ABC34501DE35'
```

---

## Geração (útil para testes)

```dart
// CNPJ alfanumérico ou numérico aleatório válido
final cnpj = CnpjAlfanumerico.generate();
assert(CnpjAlfanumerico.isValid(cnpj));

// Com máscara
final formatado = CnpjAlfanumerico.generate(formatted: true);
assert(CnpjAlfanumerico.isValid(formatado));

// Garante ao menos uma letra nos 12 primeiros caracteres
final alfanumerico = CnpjAlfanumerico.generate(forceAlphanumeric: true);
assert(CnpjAlfanumerico.isValid(alfanumerico));
```

---

## Máscara de campo

```dart
// Exemplo oficial válido → '12.ABC.345/01DE-35'
TextField(
  keyboardType: TextInputType.text,
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [CnpjAlfaMask()],
)
```

---

## TextEditingController com CNPJ pré-formatado

```dart
// Exemplo oficial válido, pré-formatado no controller
final cnpjAlfaController = TextEditingController(
  text: CnpjAlfanumerico.format('12ABC34501DE35'),
);
```

---

← [Voltar ao README](../README.md)
