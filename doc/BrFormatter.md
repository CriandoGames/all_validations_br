# BrFormatter — Formatação e Geração de Documentos BR

`BrFormatter` formata, limpa e **gera** dados tipicamente brasileiros — CPF, CNPJ, CEP, telefone, moeda e quilometragem — sem dependências externas.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

> Para datas e horas, veja [`BrData`](BrData.md). Para CNPJ alfanumérico 2026, veja [`CnpjAlfanumerico`](CnpjAlfanumerico.md).

---

## CPF

```dart
// Formata (11 dígitos → máscara)
BrFormatter.formatCpf('52998224725');   // '529.982.247-25'
BrFormatter.formatCpf('529.982.247-25'); // '529.982.247-25' (já formatado, aceito)

// Remove máscara
BrFormatter.stripCpf('529.982.247-25'); // '52998224725'
BrFormatter.stripCpf('52998224725');    // '52998224725' (sem máscara, sem efeito)
```

`formatCpf` lança `ArgumentError` se o resultado após strip não tiver exatamente 11 dígitos:

```dart
BrFormatter.formatCpf('123');         // ❌ ArgumentError
BrFormatter.formatCpf('');            // ❌ ArgumentError
BrFormatter.formatCpf('abc');         // ❌ ArgumentError (0 dígitos após strip)
```

### Geração de CPF

Usa `Random.secure()` e calcula os dígitos verificadores pelo algoritmo oficial. Rejeita automaticamente sequências com 11 dígitos iguais (ex: `111.111.111-11`).

```dart
BrFormatter.generateCpf();                  // '52998224725'  (dígitos puros)
BrFormatter.generateCpf(formatted: true);   // '529.982.247-25'
```

---

## CNPJ numérico

```dart
// Formata (14 dígitos → máscara)
BrFormatter.formatCnpj('11222333000181');     // '11.222.333/0001-81'
BrFormatter.formatCnpj('11.222.333/0001-81'); // '11.222.333/0001-81' (já formatado)

// Remove máscara
BrFormatter.stripCnpj('11.222.333/0001-81'); // '11222333000181'
```

`formatCnpj` lança `ArgumentError` se o resultado após strip não tiver exatamente 14 dígitos.

### Geração de CNPJ

Usa `Random.secure()` com os pesos oficiais da Receita Federal.

```dart
BrFormatter.generateCnpj();                  // '11222333000181'
BrFormatter.generateCnpj(formatted: true);   // '11.222.333/0001-81'
```

> Para CNPJ alfanumérico 2026, use `CnpjAlfanumerico.generate(forceAlphanumeric: true)`.

---

## CEP

```dart
// Formata (8 dígitos → máscara)
BrFormatter.formatCep('01310100');   // '01310-100'
BrFormatter.formatCep('01310-100');  // '01310-100' (já formatado)

// Remove máscara
BrFormatter.stripCep('01310-100');   // '01310100'
```

`formatCep` lança `ArgumentError` se o resultado após strip não tiver exatamente 8 dígitos.

---

## Telefone

```dart
// Celular (11 dígitos) → '(DDD) XXXXX-XXXX'
BrFormatter.formatPhone('11999998877');   // '(11) 99999-8877'

// Fixo (10 dígitos) → '(DDD) XXXX-XXXX'
BrFormatter.formatPhone('1133334444');    // '(11) 3333-4444'

// Omitir DDD (funciona para fixo e celular)
BrFormatter.formatPhone('11999998877', ddd: false); // '99999-8877'
BrFormatter.formatPhone('1133334444',  ddd: false); // '3333-4444'

// Extrair apenas o DDD
BrFormatter.extractDdd('11999998877'); // '11'
BrFormatter.extractDdd('1133334444');  // '11'

// Remove máscara
BrFormatter.stripPhone('(11) 99999-8877'); // '11999998877'
BrFormatter.stripPhone('11 99999-8877');   // '11999998877'
```

`formatPhone` lança `ArgumentError` se o resultado após strip não tiver 10 ou 11 dígitos:

```dart
BrFormatter.formatPhone('119999');   // ❌ ArgumentError (6 dígitos)
BrFormatter.formatPhone('');         // ❌ ArgumentError
```

---

## Moeda

### Formatação

```dart
BrFormatter.formatCurrency(1234.56);                    // 'R$ 1.234,56'
BrFormatter.formatCurrency(1234.5);                     // 'R$ 1.234,50'  (arredonda para 2 casas)
BrFormatter.formatCurrency(85437107.04);                // 'R$ 85.437.107,04'
BrFormatter.formatCurrency(0.99);                       // 'R$ 0,99'
BrFormatter.formatCurrency(0);                          // 'R$ 0,00'

// Sem símbolo R$
BrFormatter.formatCurrency(1234.56, symbol: false);     // '1.234,56'

// Sem casas decimais
BrFormatter.formatCurrency(1234.0, decimals: 0);        // 'R$ 1.234'
BrFormatter.formatCurrency(1234.56, decimals: 0);       // 'R$ 1.235'  (arredonda)

// Mais casas decimais
BrFormatter.formatCurrency(1.5, decimals: 4);           // 'R$ 1,5000'
```

### Parse

Converte string monetária → `double`. Funciona com ou sem o símbolo `R$`:

```dart
BrFormatter.parseCurrency('R$ 1.234,56');  // 1234.56
BrFormatter.parseCurrency('1.234,56');     // 1234.56
BrFormatter.parseCurrency('99,90');        // 99.9
BrFormatter.parseCurrency('0,01');         // 0.01
```

Lança `FormatException` se a string não for convertível:

```dart
BrFormatter.parseCurrency('abc');    // ❌ FormatException
BrFormatter.parseCurrency('');       // ❌ FormatException
```

### Strip do símbolo

Remove os caracteres `R`, `$` e espaços da string:

```dart
BrFormatter.stripCurrencySymbol('R$ 99,90');   // '99,90'
BrFormatter.stripCurrencySymbol('R$ 1.234,56'); // '1.234,56'
```

> ⚠️ O regex interno remove qualquer ocorrência dos caracteres `R`, `$` e espaço, não apenas o prefixo `R$`. Valores que contenham esses chars por outros motivos serão afetados. Prefira `parseCurrency` para converter para `double`.

---

## KM

```dart
BrFormatter.formatKm(999);      // '999 km'
BrFormatter.formatKm(1000);     // '1.000 km'
BrFormatter.formatKm(85437);    // '85.437 km'
BrFormatter.formatKm(1000000);  // '1.000.000 km'

// Suporta valores negativos (ex: variação de odômetro)
BrFormatter.formatKm(-500);     // '-500 km'
BrFormatter.formatKm(-85437);   // '-85.437 km'
```

---

## TextEditingController com dados pré-formatados

```dart
final cpfController = TextEditingController(
  text: BrFormatter.formatCpf('52998224725'),       // '529.982.247-25'
);

final cnpjController = TextEditingController(
  text: BrFormatter.formatCnpj('11222333000181'),   // '11.222.333/0001-81'
);

final cnpjAlfaController = TextEditingController(
  text: CnpjAlfanumerico.format('AB1CD2EF000199'), // 'AB.1CD.2EF/0001-99'
);

final celularController = TextEditingController(
  text: BrFormatter.formatPhone('11999998877'),     // '(11) 99999-8877'
);

final cepController = TextEditingController(
  text: BrFormatter.formatCep('01310100'),          // '01310-100'
);

final valorController = TextEditingController(
  text: BrFormatter.formatCurrency(1234.56),        // 'R$ 1.234,56'
);
```

---

## Exceções

| Método | Exceção | Condição |
|--------|---------|----------|
| `formatCpf` | `ArgumentError` | ≠ 11 dígitos após strip |
| `formatCnpj` | `ArgumentError` | ≠ 14 dígitos após strip |
| `formatCep` | `ArgumentError` | ≠ 8 dígitos após strip |
| `formatPhone` | `ArgumentError` | ≠ 10 ou 11 dígitos após strip |
| `parseCurrency` | `FormatException` | string não conversível para double |

---

## Referência rápida

| Método | Entrada | Saída |
|--------|---------|-------|
| `formatCpf(s)` | `'52998224725'` | `'529.982.247-25'` |
| `stripCpf(s)` | `'529.982.247-25'` | `'52998224725'` |
| `generateCpf({formatted})` | — | CPF válido aleatório |
| `formatCnpj(s)` | `'11222333000181'` | `'11.222.333/0001-81'` |
| `stripCnpj(s)` | `'11.222.333/0001-81'` | `'11222333000181'` |
| `generateCnpj({formatted})` | — | CNPJ válido aleatório |
| `formatCep(s)` | `'01310100'` | `'01310-100'` |
| `stripCep(s)` | `'01310-100'` | `'01310100'` |
| `formatPhone(s, {ddd})` | `'11999998877'` | `'(11) 99999-8877'` |
| `stripPhone(s)` | `'(11) 99999-8877'` | `'11999998877'` |
| `extractDdd(s)` | `'11999998877'` | `'11'` |
| `formatCurrency(v, {symbol, decimals})` | `1234.56` | `'R$ 1.234,56'` |
| `parseCurrency(s)` | `'R$ 1.234,56'` | `1234.56` |
| `stripCurrencySymbol(s)` | `'R$ 99,90'` | `'99,90'` |
| `formatKm(n)` | `85437` | `'85.437 km'` |

---

← [Voltar ao README](../README.md)
