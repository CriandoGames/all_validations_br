# HelperUtil — Funções Avançadas e Utilitários

Classe de propósito geral com utilitários de texto, datas, UUIDs, JWT, PIX, senhas e informações de plataforma — tudo em Dart puro, sem dependências externas.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Manipulação de texto

```dart
// Conta palavras separadas por espaço
HelperUtil.countWords('Flutter é incrível'); // 3
HelperUtil.countWords('');                   // 0

// Remove tags HTML, retorna texto limpo
HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>'); // 'Hello World'
HelperUtil.removeHtmlTags('<br/>');                      // ''

// Capitaliza a primeira letra de cada palavra
HelperUtil.capitalizeWords('olá mundo flutter'); // 'Olá Mundo Flutter'
HelperUtil.capitalizeWords('');                  // ''
```

---

## Manipulação de strings e números

```dart
// Remove tudo que não for dígito (0–9)
HelperUtil.removeNonNumeric('(11) 99999-8877'); // '11999998877'
HelperUtil.removeNonNumeric('R$ 1.234,56');     // '1234'

// String aleatória com letras e dígitos
HelperUtil.generateRandomString(8);  // ex: 'aB3xZ9mQ'
HelperUtil.generateRandomString(16); // ex: 'kR7mQzA1bW4nXoP2'

// Inteiro aleatório no intervalo [min, max] (inclusive)
HelperUtil.generateRandomInt(1, 6);   // dado de 6 faces
HelperUtil.generateRandomInt(0, 100); // 0 a 100
```

---

## Matemática

```dart
// Calcula percentual de um valor sobre um total
HelperUtil.calculatePercentage(25, 200); // 12.5
HelperUtil.calculatePercentage(1, 3);    // 33.333...

// Lança ArgumentError se total == 0
// HelperUtil.calculatePercentage(10, 0); // ❌ ArgumentError
```

---

## Datas e horários

```dart
// Converte UTC → horário local do dispositivo
final local = HelperUtil.convertUtcToLocal(DateTime.utc(2026, 6, 27, 12, 0));

// Converte horário local → UTC
final utc = HelperUtil.convertLocalToUtc(DateTime(2026, 6, 27, 9, 0));

// Diferença total em dias entre duas datas
HelperUtil.daysBetween(DateTime(2026, 1, 1), DateTime(2026, 12, 31)); // 364

// Dias úteis (exclui sábado e domingo, não considera feriados)
HelperUtil.businessDaysBetween(DateTime(2026, 6, 1), DateTime(2026, 6, 30)); // 22

// Verifica se o ano é bissexto
HelperUtil.isLeapYear(2024); // true
HelperUtil.isLeapYear(2025); // false
HelperUtil.isLeapYear(1900); // false (divisível por 100 mas não por 400)
HelperUtil.isLeapYear(2000); // true  (divisível por 400)
```

---

## Validação de data, idade e maioridade

```dart
// Verifica se a data existe de verdade (bissextos, meses com 30/31 dias etc.)
// Formatos aceitos: 'dd/MM/yyyy' ou 'yyyy-MM-dd'
HelperUtil.isValidDate('29/02/2024'); // true  (2024 é bissexto)
HelperUtil.isValidDate('29/02/2023'); // false (2023 não é bissexto)
HelperUtil.isValidDate('31/04/2026'); // false (abril tem 30 dias)
HelperUtil.isValidDate('15/06/2023'); // true
HelperUtil.isValidDate('2023-06-15'); // true  (formato ISO)

// Calcula idade exata em anos
HelperUtil.calculateAge(DateTime(1990, 5, 15)); // 36 (em 2026)
HelperUtil.calculateAge(DateTime(2026, 12, 31)); // 0 (ainda não fez aniversário)

// Verifica maioridade (padrão: 18 anos; customizável com minAge)
HelperUtil.isAdult(DateTime(2000, 1, 1));              // true
HelperUtil.isAdult(DateTime(2010, 1, 1));              // false
HelperUtil.isAdult(DateTime(2005, 1, 1), minAge: 21); // false
HelperUtil.isAdult(DateTime(2002, 1, 1), minAge: 21); // true (em 2026)
```

---

## UUID

Gera identificadores únicos nos três formatos mais usados, sem dependências externas.

```dart
// v4 — aleatório (mais comum em geral)
HelperUtil.generateUUIDv4();
// '550e8400-e29b-41d4-a716-446655440000'

// v3 — determinístico, baseado em namespace + nome via MD5
// Mesmo namespace + nome sempre produz o mesmo UUID
HelperUtil.generateUUIDv3(
  '6ba7b810-9dad-11d1-80b4-00c04fd430c8', // namespace (UUID do DNS, por ex.)
  'minha-entidade',
);
// resultado consistente para esses mesmos inputs

// v5 — determinístico, baseado em namespace + nome via SHA-1
// Preferível ao v3 quando consistência criptográfica importa
HelperUtil.generateUUIDv5(
  '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
  'minha-entidade',
);
```

> **Nota:** os parâmetros de `generateUUIDv3` e `generateUUIDv5` são **posicionais**, não nomeados.

---

## JWT

Utilitários para inspecionar tokens JWT sem validar a assinatura — útil no lado cliente para ler claims como `role`, `sub` ou verificar expiração antes de uma requisição.

> ⚠️ Estes métodos **não validam a assinatura** do token. Para validação criptográfica real, faça no servidor.

```dart
// Decodifica o payload e retorna como Map, ou null se malformado
final payload = HelperUtil.decodeJWT(token);
// { 'sub': '1234567890', 'role': 'admin', 'exp': 1893456000 }

// Verifica se o token está expirado (compara claim 'exp' com DateTime.now())
// Retorna true se expirado OU se não houver claim 'exp'
bool expirado = HelperUtil.isJwtExpired(token);

// Verifica se uma claim específica existe no payload
bool temRole = HelperUtil.hasJwtClaim(token, 'role'); // true

// Obtém o valor de uma claim (retorna null se ausente)
dynamic role   = HelperUtil.getJwtClaim(token, 'role');   // 'admin'
dynamic userId = HelperUtil.getJwtClaim(token, 'sub');    // '1234567890'
dynamic exp    = HelperUtil.getJwtClaim(token, 'exp');    // 1893456000 (int)
dynamic nulo   = HelperUtil.getJwtClaim(token, 'naoexiste'); // null
```

---

## Senhas simples

> ⚠️ **Atenção:** estes métodos usam um hash customizado simples, **não adequado para armazenamento de senhas em produção**. Para dados sensíveis, use [`CryptUtil`](CryptUtil.md) (ChaCha20-Poly1305) ou uma biblioteca de hashing de senhas como `bcrypt` / `argon2`.
>
> Use `encryptPassword`/`validatePassword` apenas em contextos de baixo risco, como PINs de demonstração ou senhas de acesso local sem dados críticos.

```dart
// Gera um hash derivado de salt + securityKey + password
// Retorna uma string no formato 'salt:hash'
final hash = HelperUtil.encryptPassword(
  'minha-senha',    // senha do usuário
  'chave-secreta',  // chave da aplicação (mantenha constante)
  'salt-aleatorio', // salt único por usuário (gere com generateRandomString)
);
// ex: 'salt-aleatorio:a3f2b1c0'

// Valida a senha comparando com o hash armazenado
final ok = HelperUtil.validatePassword(
  'minha-senha',  // senha digitada pelo usuário
  'chave-secreta',
  hash,           // hash retornado por encryptPassword
);
// true

// Exemplo de uso completo — cadastro + login
final salt     = HelperUtil.generateRandomString(16);
final stored   = HelperUtil.encryptPassword('1234', 'APP_KEY', salt);

// Mais tarde, no login:
bool valido = HelperUtil.validatePassword('1234', 'APP_KEY', stored); // true
bool errado = HelperUtil.validatePassword('0000', 'APP_KEY', stored); // false
```

---

## Chaves PIX

Valida e identifica o tipo de uma chave PIX seguindo a ordem de validação do BACEN.

```dart
// Retorna: 'CPF', 'Celular', 'Email', 'Chave Aleatória', ou null
HelperUtil.validatePixKey('992.864.791-74');                          // 'CPF'
HelperUtil.validatePixKey('99286479174');                             // 'CPF' (sem máscara)
HelperUtil.validatePixKey('+5511912345678');                          // 'Celular'
HelperUtil.validatePixKey('user@example.com');                        // 'Email'
HelperUtil.validatePixKey('123e4567-e89b-4d3a-a456-426614174000');   // 'Chave Aleatória'
HelperUtil.validatePixKey('12345678901');                             // null (CPF inválido)
HelperUtil.validatePixKey('');                                        // null

// Mascara a chave para exibição segura (não expõe dados completos)
HelperUtil.maskPixKey('99286479174');
// '992.***.***-74'

HelperUtil.maskPixKey('+5511912345678');
// '+5511*****678'

HelperUtil.maskPixKey('user@example.com');
// 'us**@example.com'

HelperUtil.maskPixKey('123e4567-e89b-4d3a-a456-426614174000');
// '123e4567-****-****-****-426614174000'
```

**Ordem de validação (conforme BACEN):**
1. **CPF** — 11 dígitos com dígitos verificadores válidos (aceita com ou sem máscara)
2. **Celular** — formato E.164 obrigatório: `+55` + DDD + número iniciando com `9`
3. **E-mail** — endereço válido
4. **Chave aleatória** — UUID v4

> Se o valor contiver apenas dígitos, e-mail e chave aleatória são descartados imediatamente (otimização).

---

## Informações da plataforma

```dart
final info = HelperUtil.getDeviceInfo();
// {
//   'platform': 'android',  // nome da plataforma (android, ios, web, windows…)
//   'isWeb': false,          // true quando rodando no navegador
// }

print(info['platform']); // 'android'
print(info['isWeb']);    // false
```

---

## Métodos descontinuados

Os métodos abaixo ainda funcionam mas estão marcados como `@Deprecated` e **serão removidos em versão futura**. Migre conforme indicado:

| Método antigo | Substituto recomendado |
|---------------|------------------------|
| `HelperUtil.formatText(input, 'cpf')` | `BrFormatter.formatCpf(input)` |
| `HelperUtil.formatText(input, 'cnpj')` | `BrFormatter.formatCnpj(input)` |
| `HelperUtil.formatText(input, 'celular')` | `BrFormatter.formatPhone(input)` |
| `HelperUtil.formatText(input, 'dinheiro')` | `BrFormatter.formatCurrency(double.parse(input))` |
| `HelperUtil.formatText(input, 'data')` | `BrData.format(DateTime)` |
| `HelperUtil.formatCurrency(value)` | `BrFormatter.formatCurrency(value)` |

---

## Referência rápida

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `countWords(text)` | `int` | Conta palavras |
| `removeHtmlTags(input)` | `String` | Remove tags HTML |
| `capitalizeWords(input)` | `String` | Capitaliza palavras |
| `removeNonNumeric(input)` | `String` | Remove não-dígitos |
| `generateRandomString(length)` | `String` | String aleatória |
| `generateRandomInt(min, max)` | `int` | Inteiro aleatório |
| `calculatePercentage(value, total)` | `double` | Percentual |
| `convertUtcToLocal(dt)` | `DateTime` | UTC → local |
| `convertLocalToUtc(dt)` | `DateTime` | Local → UTC |
| `daysBetween(start, end)` | `int` | Dias totais |
| `businessDaysBetween(start, end)` | `int` | Dias úteis |
| `isLeapYear(year)` | `bool` | Ano bissexto? |
| `isValidDate(date)` | `bool` | Data existe? |
| `calculateAge(birthDate)` | `int` | Idade em anos |
| `isAdult(birthDate, {minAge})` | `bool` | Maioridade |
| `generateUUIDv4()` | `String` | UUID aleatório |
| `generateUUIDv3(ns, name)` | `String` | UUID determinístico MD5 |
| `generateUUIDv5(ns, name)` | `String` | UUID determinístico SHA-1 |
| `decodeJWT(token)` | `Map?` | Payload do JWT |
| `isJwtExpired(token)` | `bool` | JWT expirado? |
| `hasJwtClaim(token, claim)` | `bool` | Claim existe? |
| `getJwtClaim(token, claim)` | `dynamic` | Valor da claim |
| `encryptPassword(pass, key, salt)` | `String` | Hash simples |
| `validatePassword(pass, key, hash)` | `bool` | Valida hash |
| `validatePixKey(key)` | `String?` | Tipo da chave PIX |
| `maskPixKey(key)` | `String` | Chave mascarada |
| `getDeviceInfo()` | `Map` | `platform` + `isWeb` |

---

← [Voltar ao README](../README.md)
