# BrZod — Validação Fluente para Flutter/Dart

`BrZod` é um validador fluente (encadeado) com foco em documentos brasileiros. Zero dependências externas, autocontido e estruturado para eventual extração como pacote standalone.

```dart
import 'package:all_validations_br/br_zod.dart';
```

---

## Uso básico — TextFormField

```dart
TextFormField(
  validator: BrZod().required().email().build,
)
```

O método `.build` retorna `String? Function(dynamic)` — compatível diretamente com o parâmetro `validator` do `TextFormField`.

---

## Referência de métodos

### Genéricos

| Método | Descrição |
|--------|-----------|
| `required([msg])` | Rejeita `null` e string vazia |
| `optional()` | Se vazio/nulo, interrompe a cadeia sem erro. **Coloque antes das demais validações.** |
| `min(n, [msg])` | Mínimo de `n` caracteres |
| `max(n, [msg])` | Máximo de `n` caracteres |
| `email([msg])` | Formato de e-mail válido |
| `phone([msg])` | Telefone BR — celular (9 dígitos) ou fixo (8 dígitos), com ou sem DDD |
| `equals(other, [msg])` | Valor deve ser igual a `other` — útil para confirmação de senha |
| `type<T>([msg])` | Valor deve ser do tipo `T` (`String`, `int`, `double`, `bool`) |
| `isDate([msg])` | Data válida — aceita `dd/MM/yyyy`, `yyyy-MM-dd` e ISO 8601 |
| `isBefore(max, [msg])` | Data anterior a `max` |
| `isAfter(min, [msg])` | Data posterior a `min` |
| `custom(fn, {msg})` | Validação arbitrária — `fn` recebe o valor e retorna `bool` |

### Documentos brasileiros

| Método | Documento |
|--------|-----------|
| `cpf([msg])` | CPF — mod-11 em 11 dígitos, rejeita sequências iguais |
| `cnpj([msg])` | CNPJ numérico — mod-11 em 14 dígitos |
| `cnpjAlfa([msg])` | CNPJ alfanumérico — IN RFB 2229/2024 (vigente jul/2026) |
| `cpfOuCnpj([msg])` | CPF **ou** CNPJ numérico — útil em campos de documento genérico |
| `cep([msg])` | CEP — `00000-000` ou `00000000` |
| `rg([msg])` | RG — formato mais comum, aceita dígito X |
| `placa([msg])` | Placa — formato antigo (`ABC-1234`) e Mercosul (`ABC1D23`) |
| `cnh([msg])` | CNH — 11 dígitos, dois DVs via mod-11 |
| `renavam([msg])` | RENAVAM — 9 ou 11 dígitos, mod-11 |
| `pisPasep([msg])` | PIS/PASEP — 11 dígitos, mod-11 |
| `tituloEleitor([msg])` | Título de Eleitor — 12 dígitos, dois DVs, código de estado |
| `cns([msg])` | CNS (Cartão Nacional de Saúde) — 15 dígitos, algoritmo DATASUS |

### Segurança

| Método | Descrição |
|--------|-----------|
| `password({policy, msg})` | Senha conforme `PasswordPolicy`. Padrão: forte (8+, maiúscula, minúscula, número, símbolo) |
| `uuid({version, msg})` | UUID — `'3'`, `'4'`, `'5'` ou `'all'` (padrão) |
| `url([msg])` | URL com esquema `http`, `https` ou `ftp` |
| `ipv4([msg])` | Endereço IPv4 (`0.0.0.0` – `255.255.255.255`) |
| `ipv6([msg])` | Endereço IPv6 — formato completo ou comprimido |
| `regex(pattern, {msg})` | Corresponde ao padrão regex arbitrário fornecido |

---

## Exemplos de encadeamento

```dart
// Campos simples
BrZod().required().min(3).build
BrZod().required().email().build
BrZod().required().cpf().build
BrZod().required().cnpj().build

// Campo opcional — vazio OK, preenchido valida
BrZod().optional().email().build
BrZod().optional().cep().build

// Confirmação de senha
final senha = TextEditingController();
BrZod().required().password().build                          // campo senha
BrZod().required().equals(senha.text, 'Senhas não conferem').build // confirmação

// Data com range
BrZod().required().isDate().isAfter(DateTime(2000)).build

// Regex customizado
BrZod().required().regex(r'^\d{4}$', message: 'Apenas 4 dígitos').build

// Custom arbitrário
BrZod().required().custom((v) => v != 'admin', message: 'Nome reservado').build
```

---

## PasswordPolicy

Configuração reutilizável de política de senha:

```dart
// Presets prontos
BrZod().required().password(policy: PasswordPolicy.weak).build   // 6+ chars
BrZod().required().password(policy: PasswordPolicy.medium).build // 6+, maiúsc, minúsc, número
BrZod().required().password(policy: PasswordPolicy.strong).build // padrão: 8+, todos os requisitos

// Customizada
const myPolicy = PasswordPolicy(
  minLength: 12,
  requireUppercase: true,
  requireLowercase: true,
  requireNumber: true,
  requireSpecial: false,
);
BrZod().required().password(policy: myPolicy).build
```

| Preset | Comprimento mínimo | Maiúscula | Minúscula | Número | Símbolo |
|--------|--------------------|-----------|-----------|--------|---------|
| `weak` | 6 | — | — | — | — |
| `medium` | 6 | ✓ | ✓ | ✓ | — |
| `strong` *(padrão)* | 8 | ✓ | ✓ | ✓ | ✓ |

---

## Mensagens customizadas

Todo método aceita uma mensagem opcional como primeiro argumento posicional (ou `message:` no caso de `custom`, `uuid`, `password`, `regex`):

```dart
BrZod().required('Preencha este campo').cpf('CPF inválido').build
BrZod().required().min(8, 'Mínimo 8 caracteres').build
BrZod().required().password(message: 'Senha muito fraca').build
BrZod().required().regex(r'^\d+$', message: 'Apenas números').build
```

---

## Locale customizado

O locale controla todas as mensagens de erro padrão. O padrão é PT-BR.

### Global (toda a aplicação)

```dart
// No main() ou antes de usar BrZod:
BrZod.defaultLocale = MyCustomLocale();
```

### Por instância

```dart
BrZod(locale: MyCustomLocale()).required().cpf().build
```

### Criando seu próprio locale

Implemente a interface `ILocaleBrZod` (30 membros):

```dart
class MyLocale implements ILocaleBrZod {
  @override String get required => 'Field is required';
  @override String get email    => 'Invalid email';
  @override String min(int n)   => 'At least $n characters';
  // ... demais membros
}
```

---

## Validação de Map — `BrZod.validate()`

Útil para validar payloads de API, formulários em bloco ou qualquer `Map<String, dynamic>`.

```dart
final result = BrZod.validate(
  data: {
    'email': 'user@example.com',
    'cpf':   '529.982.247-25',
    'cep':   '01310-100',
  },
  params: {
    'email': BrZod().required().email(),
    'cpf':   BrZod().required().cpf(),
    'cep':   BrZod().optional().cep(),
  },
);

if (result.isNotValid) {
  print(result.errors);    // Map com os erros por campo
  print(result.errorList); // ['email: Informe um e-mail válido', ...]
}
```

### Aninhamento

```dart
final result = BrZod.validate(
  data: {
    'user': {
      'email': 'user@example.com',
      'cpf':   '529.982.247-25',
    },
    'address': {'cep': '01310-100'},
  },
  params: {
    'user': {
      'email': BrZod().required().email(),
      'cpf':   BrZod().required().cpf(),
    },
    'address': {
      'cep': BrZod().required().cep(),
    },
  },
);

// Acesso estruturado:
final userErrors = result.errors['user'] as Map<String, dynamic>?;
// errorList usa notação de ponto: 'user.email: ...'
```

### `BrZodResult`

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `isValid` | `bool` | `true` se não há erros |
| `isNotValid` | `bool` | Inverso de `isValid` |
| `errors` | `Map<String, dynamic>` | Mapa estruturado de erros (suporta aninhamento) |
| `errorList` | `List<String>` | Lista plana de strings `'campo: mensagem'` |

---

## Estrutura do módulo

```
lib/
  br_zod.dart                    ← importação pública
  src/br_zod/
    br_zod.dart                  ← classe principal + exports
    locale/
      i_locale_br_zod.dart       ← interface ILocaleBrZod (30 membros)
      locale_pt_br.dart          ← implementação PT-BR padrão
    models/
      br_zod_result.dart         ← BrZodResult
    validations/
      generic.dart               ← funções puras: required, email, phone…
      br.dart                    ← funções puras: CPF, CNPJ, CNH, CNS…
      security.dart              ← funções puras: password, UUID, URL…
```

Os arquivos em `validations/` são **funções puras** — testáveis de forma isolada e prontos para extração como pacote standalone.
