# BrInputMask — Máscaras de Campo

Todas as máscaras estendem `BrInputMask` (que estende `TextInputFormatter` do Flutter) e possuem `const` constructors — zero custo de instanciação. Basta adicioná-las ao `inputFormatters` de qualquer `TextField`.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Como funciona

`BrInputMask` é a classe base abstrata. Ela oferece três helpers estáticos disponíveis para todas as subclasses:

| Helper | O que faz |
|--------|-----------|
| `BrInputMask.digits(text)` | Remove tudo que não for dígito `0–9` |
| `BrInputMask.alphanumeric(text)` | Remove tudo que não for `[A-Z0-9]`, já em maiúsculas |
| `BrInputMask.collapsed(text)` | Retorna `TextEditingValue` com cursor no final |

As RegExps internas são `static final` — compiladas uma única vez e reutilizadas em cada keystroke. Por isso o uso de `const` constructor é recomendado: o Flutter pode reutilizar a mesma instância sem custo extra.

---

## Documentos de identidade

### CPF

Máscara: `999.999.999-99` · máx 11 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CpfMask()],
)
```

Progressão de digitação:
- `'1'`           → `'1'`
- `'1234'`        → `'123.4'`
- `'123456789'`   → `'123.456.789'`
- `'12345678901'` → `'123.456.789-01'`

---

### CNPJ numérico

Máscara: `99.999.999/9999-99` · máx 14 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CnpjMask()],
)
```

Progressão de digitação:
- `'11'`             → `'11'`
- `'11222'`          → `'11.222'`
- `'11222333'`       → `'11.222.333'`
- `'112223330001'`   → `'11.222.333/0001'`
- `'11222333000181'` → `'11.222.333/0001-81'`

---

### CNPJ alfanumérico 2026

Máscara: `XX.XXX.XXX/XXXX-VV` · máx 14 chars `[A-Z0-9]`

Aceita letras maiúsculas e dígitos nas 12 primeiras posições. Letras minúsculas são convertidas automaticamente. Os dois dígitos verificadores (posições 13–14) devem ser sempre numéricos — a validação do conteúdo é feita via [`CnpjAlfanumerico.isValid`](CnpjAlfanumerico.md).

```dart
TextField(
  keyboardType: TextInputType.text,
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [CnpjAlfaMask()],
)
```

Progressão de digitação:
- `'AB'`             → `'AB'`
- `'AB123'`          → `'AB.123'`
- `'AB123CDE'`       → `'AB.123.CDE'`
- `'AB123CDE0001'`   → `'AB.123.CDE/0001'`
- `'AB123CDE000139'` → `'AB.123.CDE/0001-39'`

---

### CPF ou CNPJ dinâmico

Alterna automaticamente entre CPF e CNPJ conforme o usuário digita — sem precisar de dois campos separados.

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CpfOuCnpjMask()],
)
```

Progressão:
- `'12345678901'`    → `'123.456.789-01'` (≤ 11 dígitos → CPF)
- `'123456789012'`   → `'12.345.678/9012'` (12° dígito → chaveou para CNPJ)
- `'11222333000181'` → `'11.222.333/0001-81'` (14 dígitos → CNPJ completo)

> Ao apagar o 12° dígito, o campo volta automaticamente para o formato CPF.

---

## Contato e endereço

### Telefone

Máscara dinâmica: `(99) 9999-9999` (fixo, 10 dígitos) ou `(99) 99999-9999` (celular, 11 dígitos). O traço se move automaticamente ao adicionar ou remover o 11º dígito.

```dart
TextField(
  keyboardType: TextInputType.phone,
  inputFormatters: [PhoneMask()],
)
```

Progressão:
- `'11'`          → `'(11'`
- `'113'`         → `'(11) 3'`
- `'1133334444'`  → `'(11) 3333-4444'`  (fixo)
- `'11999998877'` → `'(11) 99999-8877'` (celular)

---

### CEP

Máscara: `99999-999` · máx 8 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CepMask()],
)
```

Progressão:
- `'01310'`    → `'01310'`
- `'013101'`   → `'01310-1'`
- `'01310100'` → `'01310-100'`

---

## Data e hora

### Data

Máscara: `DD/MM/AAAA` · máx 8 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [DateMask()],
)
```

Progressão:
- `'01'`       → `'01'`
- `'011'`      → `'01/1'`
- `'0107'`     → `'01/07'`
- `'01072026'` → `'01/07/2026'`

---

### Hora

Máscara: `HH:MM` · máx 4 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [TimeMask()],
)
```

Progressão:
- `'14'`   → `'14'`
- `'143'`  → `'14:3'`
- `'1430'` → `'14:30'`

---

## Valores monetários

### Moeda (com prefixo R$)

Abordagem **centavos da direita para a esquerda**: os dígitos preenchem sempre a partir dos centavos, crescendo para a esquerda. Valor máximo: `R$ 99.999.999.999,99` (13 dígitos).

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CurrencyMask()],
)
```

| Dígitos digitados | Campo exibe        |
|-------------------|--------------------|
| `'1'`             | `'R$ 0,01'`        |
| `'12'`            | `'R$ 0,12'`        |
| `'123'`           | `'R$ 1,23'`        |
| `'1234'`          | `'R$ 12,34'`       |
| `'123456'`        | `'R$ 1.234,56'`    |
| `'12345678'`      | `'R$ 123.456,78'`  |

---

### Centavos (sem prefixo R$)

Mesma lógica da `CurrencyMask`, mas sem o símbolo — útil quando `R$` já aparece na `InputDecoration` como `prefixText`.

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CentavosMask()],
  decoration: InputDecoration(prefixText: 'R\$ '),
)
```

| Dígitos digitados | Campo exibe    |
|-------------------|----------------|
| `'1'`             | `'0,01'`       |
| `'7194'`          | `'71,94'`      |
| `'1234567'`       | `'12.345,67'`  |

---

## Cartão de crédito / débito

### Número do cartão

Máscara: `XXXX XXXX XXXX XXXX` · máx 16 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CardMask()],
)
```

Progressão:
- `'4111'`             → `'4111'`
- `'41111'`            → `'4111 1'`
- `'4111111111111111'` → `'4111 1111 1111 1111'`

---

### Validade

Formato dinâmico: `MM/AA` (4 dígitos) ou `MM/AAAA` (6 dígitos). Alterna a partir do 5° dígito.

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CardExpiryMask()],
)
```

Progressão:
- `'1224'`   → `'12/24'`   (MM/AA)
- `'122024'` → `'12/2024'` (MM/AAAA)

---

## Placa de veículo

Aceita os dois formatos brasileiros. Converte automaticamente para maiúsculas — `keyboardType` pode ser omitido pois a placa combina letras e números.

```dart
TextField(
  textCapitalization: TextCapitalization.characters,
  inputFormatters: [PlacaMask()],
)
```

| Entrada    | Saída       | Formato      |
|------------|-------------|--------------|
| `'ABC1'`   | `'ABC-1'`   | —            |
| `'ABC1234'`| `'ABC-1234'`| Antigo       |
| `'ABC1D23'`| `'ABC-1D23'`| Mercosul     |

---

## Quilometragem

Máscara: separador de milhar `.` · máx 7 dígitos · máximo `9.999.999 km`

Zeros à esquerda são removidos automaticamente: `'0001000'` → `'1.000'`.

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [KmMask()],
)
```

Progressão:
- `'999'`     → `'999'`
- `'1000'`    → `'1.000'`
- `'999999'`  → `'999.999'`
- `'9999999'` → `'9.999.999'`

---

## NCM — Nomenclatura Comum do Mercosul

Máscara: `XXXX.XX.XX` · máx 8 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [NcmMask()],
)
```

Progressão:
- `'1234'`     → `'1234'`
- `'12345'`    → `'1234.5'`
- `'123456'`   → `'1234.56'`
- `'12345678'` → `'1234.56.78'`

---

## CNS — Cartão Nacional de Saúde

Máscara: `XXX XXXX XXXX XXXX` · máx 15 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CnsMask()],
)
```

Progressão:
- `'111'`             → `'111'`
- `'1112'`            → `'111 2'`
- `'1112222'`         → `'111 2222'`
- `'111222233334444'` → `'111 2222 3333 4444'`

---

## Medidas

### Altura

Máscara: `X,XX` · máx 3 dígitos · preenchimento da **esquerda para a direita**

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [AlturaMask()],
  decoration: InputDecoration(suffixText: 'm'),
)
```

Progressão:
- `'1'`   → `'1'`
- `'17'`  → `'1,7'`
- `'175'` → `'1,75'`

---

### Peso

Máscara: `XXX,X` · máx 4 dígitos · preenchimento da **esquerda para a direita**

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [PesoMask()],
  decoration: InputDecoration(suffixText: 'kg'),
)
```

Progressão:
- `'70'`   → `'70'`
- `'705'`  → `'705'`
- `'7051'` → `'705,1'`

---

### Temperatura

Máscara: `XX,X` · máx 3 dígitos · preenchimento da **esquerda para a direita**

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [TemperaturaMask()],
  decoration: InputDecoration(suffixText: '°C'),
)
```

Progressão:
- `'36'`  → `'36'`
- `'365'` → `'36,5'`
- `'271'` → `'27,1'`

---

## Fiscal / tributário

### CEST — Código Especificador da Substituição Tributária

Máscara: `12.345.67` · máx 7 dígitos

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CestMask()],
)
```

Progressão:
- `'12'`      → `'12'`
- `'123'`     → `'12.3'`
- `'12345'`   → `'12.345'`
- `'1234567'` → `'12.345.67'`

---

### IOF — Alíquota com 6 casas decimais

Máscara: `X,XXXXXX` · máx 7 dígitos · preenchimento da **esquerda para a direita**

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [IofMask()],
  decoration: InputDecoration(suffixText: '%'),
)
```

Progressão:
- `'1'`       → `'1'`
- `'12'`      → `'1,2'`
- `'1234567'` → `'1,234567'`
- `'0038000'` → `'0,038000'`

---

## Documentos governamentais

### NUP — Número Único de Protocolo

Formato federal: `1234567-89.0123.4.56.7890` · máx 20 dígitos

Grupos: 7 dígitos `-` 2 `.` 4 `.` 1 `.` 2 `.` 4

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [NupMask()],
)
```

Progressão:
- `'1234567'`              → `'1234567'`
- `'12345678'`             → `'1234567-8'`
- `'1234567890'`           → `'1234567-89.0'`
- `'12345678901234567890'` → `'1234567-89.0123.4.56.7890'`

---

### Certidão de Nascimento

Máscara: `000000 11 22 3333 4 55555 666 7777777 88` · máx 32 dígitos

9 grupos de dígitos separados por espaços: 6 · 2 · 2 · 4 · 1 · 5 · 3 · 7 · 2

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [CertNascimentoMask()],
)
```

Exemplo completo (32 dígitos):
- `'00000011223333455555666777777788'`
  → `'000000 11 22 3333 4 55555 666 7777777 88'`

---

## Criando uma máscara customizada

Para criar um formato próprio, estenda `BrInputMask` e implemente `formatEditUpdate`. Os helpers estáticos já estão disponíveis:

```dart
import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter/services.dart';

/// Exemplo: máscara para código de processo judicial (NNNNNNN-DD.AAAA.J.TT.OOOO)
class ProcessoMask extends BrInputMask {
  const ProcessoMask();

  static const int _maxDigits = 20;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text); // só dígitos
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 7)  buf.write('-');
      if (i == 9)  buf.write('.');
      if (i == 13) buf.write('.');
      if (i == 14) buf.write('.');
      if (i == 16) buf.write('.');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString()); // cursor sempre no final
  }
}

// Uso:
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [const ProcessoMask()],
)
```

---

## Referência rápida

| Classe | Máscara | Chars max | Tipo de entrada |
|--------|---------|-----------|-----------------|
| `CpfMask` | `999.999.999-99` | 11 | numérico |
| `CnpjMask` | `99.999.999/9999-99` | 14 | numérico |
| `CnpjAlfaMask` | `AA.BBB.CCC/DDDD-VV` | 14 | alfanumérico |
| `CpfOuCnpjMask` | CPF ou CNPJ dinâmico | 11/14 | numérico |
| `PhoneMask` | `(99) 9999-9999` / `(99) 99999-9999` | 10/11 | numérico |
| `CepMask` | `99999-999` | 8 | numérico |
| `DateMask` | `DD/MM/AAAA` | 8 | numérico |
| `TimeMask` | `HH:MM` | 4 | numérico |
| `CurrencyMask` | `R$ 9.999,99` | 13 | numérico |
| `CentavosMask` | `9.999,99` (sem R$) | 13 | numérico |
| `CardMask` | `9999 9999 9999 9999` | 16 | numérico |
| `CardExpiryMask` | `MM/AA` / `MM/AAAA` | 4/6 | numérico |
| `PlacaMask` | `AAA-9999` / `AAA-9A99` | 7 | alfanumérico |
| `KmMask` | `9.999.999` | 7 | numérico |
| `NcmMask` | `XXXX.XX.XX` | 8 | numérico |
| `CnsMask` | `XXX XXXX XXXX XXXX` | 15 | numérico |
| `AlturaMask` | `X,XX` | 3 | numérico |
| `PesoMask` | `XXX,X` | 4 | numérico |
| `TemperaturaMask` | `XX,X` | 3 | numérico |

---

← [Voltar ao README](../README.md)
