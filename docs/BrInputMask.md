# BrInputMask — Máscaras de Campo

Todas as máscaras estendem `BrInputMask` (que estende `TextInputFormatter`) e possuem `const` constructors — zero custo de instanciação. Basta adicioná-las ao `inputFormatters` do `TextField`.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## CPF, CNPJ e CNPJ Alfanumérico 2026

```dart
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

---

## CPF ou CNPJ dinâmico

Alterna automaticamente entre CPF e CNPJ conforme o usuário digita — sem necessidade de dois campos separados.

```dart
// ≤ 11 dígitos → '123.456.789-01' (CPF)
// > 11 dígitos → '11.222.333/0001-81' (CNPJ, máx 14)
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CpfOuCnpjMask()],
)
```

---

## Telefone e CEP

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

---

## Data e Hora

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

---

## Moeda

```dart
// Moeda em tempo real → 'R$ 1.234,56'
// Abordagem centavos: '1' → 'R$ 0,01'; '123456' → 'R$ 1.234,56'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CurrencyMask()],
)
```

---

## Centavos (sem prefixo R$)

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

---

## Cartão de Crédito

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

---

## Placa de Veículo

Aceita os dois formatos brasileiros: antigo (`ABC-1234`) e Mercosul (`ABC-1D23`). Converte automaticamente para maiúsculas.

```dart
// Formato antigo   → 'ABC-1234'
// Formato Mercosul → 'ABC-1D23'
TextField(
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [PlacaMask()],
)
```

---

## Quilometragem

```dart
// KM → '999.999' / '9.999.999'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [KmMask()],
)
```

---

## NCM

```dart
// NCM → '1234.56.78'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [NcmMask()],
)
```

---

## CNS — Cartão Nacional de Saúde

```dart
// CNS → '111 2222 3333 4444'
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CnsMask()],
)
```

---

## Medidas — Altura, Peso e Temperatura

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

---

## Referência rápida

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
| `CentavosMask` | `9.999,99` (sem R$) | 13 |
| `CardMask` | `9999 9999 9999 9999` | 16 |
| `CardExpiryMask` | `99/99` / `99/9999` | 4/6 |
| `PlacaMask` | `AAA-9999` / `AAA-9A99` | 7 |
| `KmMask` | `9.999.999` | 7 |
| `NcmMask` | `1234.56.78` | 8 |
| `CnsMask` | `111 2222 3333 4444` | 15 |
| `AlturaMask` | `X,XX` | 3 |
| `PesoMask` | `XXX,X` | 4 |
| `TemperaturaMask` | `XX,X` | 3 |

---

← [Voltar ao README](../README.md)
