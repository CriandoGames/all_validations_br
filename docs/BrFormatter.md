# BrFormatter — Formatação e Geração de Documentos BR

`BrFormatter` é a classe central para formatar, limpar e **gerar** dados tipicamente brasileiros — CPF, CNPJ, CEP, telefone, moeda e quilometragem — sem nenhuma dependência externa.

---

## CPF

```dart
import 'package:all_validations_br/all_validations_br.dart';

// Gera um CPF válido aleatório
final cpf = BrFormatter.generateCpf();             // '52998224725'
final cpfF = BrFormatter.generateCpf(formatted: true); // '529.982.247-25'

// Formata um CPF já existente
BrFormatter.formatCpf('52998224725'); // '529.982.247-25'

// Remove a máscara
BrFormatter.stripCpf('529.982.247-25'); // '52998224725'
```

---

## CNPJ numérico

```dart
// Gera um CNPJ numérico válido aleatório
final cnpj = BrFormatter.generateCnpj();              // '11222333000181'
final cnpjF = BrFormatter.generateCnpj(formatted: true); // '11.222.333/0001-81'

// Formata / remove máscara
BrFormatter.formatCnpj('11222333000181'); // '11.222.333/0001-81'
BrFormatter.stripCnpj('11.222.333/0001-81'); // '11222333000181'

// Para CNPJ alfanumérico 2026, use CnpjAlfanumerico:
CnpjAlfanumerico.generate(forceAlphanumeric: true, formatted: true);
```

---

## CEP e Telefone

```dart
BrFormatter.formatCep('01310100');   // '01310-100'
BrFormatter.stripCep('01310-100');   // '01310100'

BrFormatter.formatPhone('11999998877');            // '(11) 99999-8877'
BrFormatter.formatPhone('1133334444');             // '(11) 3333-4444'
BrFormatter.formatPhone('11999998877', ddd: false); // '99999-8877'
BrFormatter.extractDdd('11999998877');             // '11'
```

---

## Moeda

```dart
BrFormatter.formatCurrency(1234.56);                    // 'R$ 1.234,56'
BrFormatter.formatCurrency(85437107.04);                // 'R$ 85.437.107,04'
BrFormatter.formatCurrency(1234.56, symbol: false);     // '1.234,56'
BrFormatter.formatCurrency(1234.0,  decimals: 0);       // 'R$ 1.234'

BrFormatter.parseCurrency('R$ 1.234,56');  // 1234.56
BrFormatter.stripCurrencySymbol('R$ 99,90'); // '99,90'
```

---

## KM

```dart
BrFormatter.formatKm(85437);    // '85.437 km'
BrFormatter.formatKm(1000000);  // '1.000.000 km'
```

---

## TextEditingController com dados pré-formatados

Para inicializar um `TextEditingController` com o texto já formatado, use os métodos de formatação diretamente no atributo `text`:

```dart
// CPF → '529.982.247-25'
final cpfController = TextEditingController(
  text: BrFormatter.formatCpf('52998224725'),
);

// CNPJ numérico → '11.222.333/0001-81'
final cnpjController = TextEditingController(
  text: BrFormatter.formatCnpj('11222333000181'),
);

// CNPJ alfanumérico 2026 → 'AB.1CD.2EF/0001-99'
final cnpjAlfaController = TextEditingController(
  text: CnpjAlfanumerico.format('AB1CD2EF000199'),
);

// Celular → '(11) 99999-8877'
final celularController = TextEditingController(
  text: BrFormatter.formatPhone('11999998877'),
);

// CEP → '01310-100'
final cepController = TextEditingController(
  text: BrFormatter.formatCep('01310100'),
);

// Moeda → 'R$ 1.234,56'
final valorController = TextEditingController(
  text: BrFormatter.formatCurrency(1234.56),
);
```

---

← [Voltar ao README](../README.md)
