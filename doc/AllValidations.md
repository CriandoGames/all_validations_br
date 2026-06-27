# AllValidations — Validações Brasileiras e Utilitários

Classe principal de validações. Cobre documentos BR (CPF, CNPJ, CNH, RENAVAM, PIS/PASEP, Título de Eleitor), telefones, CEP, placas, EAN-13, cores hex, UUIDs, e-mails, URLs, hashes, arquivos e muito mais.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

> `AllValidations` é uma classe **estática** — todos os métodos são `static`, exceto `getStateByDDD` (instância). Nunca é instanciada diretamente.

---

## Tipos e formatos genéricos

```dart
AllValidations.isNull(null);          // true
AllValidations.isNull('');            // false

AllValidations.isNum('42');           // true  (int ou double)
AllValidations.isNum('3.14');         // true
AllValidations.isNum('abc');          // false

AllValidations.isNumericOnly('123');  // true  — somente dígitos, sem '.'
AllValidations.isNumericOnly('1.5');  // false

AllValidations.isNumericFloat('1.5'); // true  — aceita string vazia também
AllValidations.isNumericFloat('');    // true

AllValidations.isAlphabetOnly('abc'); // true  — sem espaço
AllValidations.isAlphabetOnly('ab1'); // false

AllValidations.isBool('true');        // true
AllValidations.isBool('false');       // true
AllValidations.isBool('yes');         // false

AllValidations.isInt('42');           // true
AllValidations.isInt('-7');           // true
AllValidations.isInt('3.14');         // false

AllValidations.isLowercase('abc');    // true
AllValidations.isLowercase('Abc');    // false

AllValidations.isUppercase('ABC');    // true
AllValidations.isUppercase('Abc');    // false

AllValidations.isBinary('1010');      // true
AllValidations.isBinary('1012');      // false

AllValidations.isJSON('{"k":"v"}');   // true
AllValidations.isJSON('not json');    // false
```

---

## E-mail e URL

```dart
AllValidations.isEmail('user@example.com');      // true
AllValidations.isEmail('user+tag@gmail.com');    // true  — '+' é permitido (RFC 5321)
AllValidations.isEmail('user@');                 // false
AllValidations.isEmail('usuário@example.com');   // false — acentos rejeitados
```

> O método aceita `+` na parte local (ex: `user+tag@gmail.com`), mas rejeita acentos e caracteres especiais como `!#<>?":\`~;[]\\|=)(*&^%`.

```dart
AllValidations.isURL('https://flutter.dev');   // true
AllValidations.isURL('flutter.dev');           // false — protocolo obrigatório
```

---

## Hashes e identificadores

```dart
AllValidations.isMD5('d41d8cd98f00b204e9800998ecf8427e');  // true (32 hex)
AllValidations.isSHA1('da39a3ee5e6b4b0d3255bfef95601890afd80709');  // true (40 hex)
AllValidations.isSHA256('e3b0c44298fc1c149afbf4c8996fb924...');      // true (64 hex)
AllValidations.isSSN('123-45-6789');     // true (Social Security Number EUA)
AllValidations.isHexadecimal('#FF5733'); // true
AllValidations.isHexadecimal('FF5733'); // true (sem #)
AllValidations.isHexadecimal('#FFF');   // true (forma abreviada)
```

### UUID

Aceita versões 3, 4 e 5. Sem argumento de versão valida qualquer UUID.

```dart
AllValidations.isUUID('550e8400-e29b-41d4-a716-446655440000');       // true (qualquer)
AllValidations.isUUID('550e8400-e29b-41d4-a716-446655440000', 4);    // true (v4)
AllValidations.isUUID('6ba7b810-9dad-31d1-80b4-00c04fd430c8', 3);    // true (v3)
AllValidations.isUUID('550e8400-e29b-21d4-a716-446655440000', 4);    // false (v2 != v4)
```

---

## Rede e datetime

```dart
AllValidations.isIPv4('192.168.1.1');   // true
AllValidations.isIPv4('999.0.0.1');     // false

AllValidations.isIPv6('::1');           // true
AllValidations.isIPv6('2001:db8::1');   // true

// DateTime no formato ISO8601 / UTC (ex: '2026-06-26 14:30:00.000Z')
AllValidations.isDateTime('2026-06-26T14:30:00.000Z');  // true
AllValidations.isDateTime('26/06/2026');                 // false — use BrData.validate
```

---

## Arquivos — verificação por extensão

```dart
// Imagens
AllValidations.isImage('photo.jpg');   // true — .jpg .jpeg .png .gif .ico .svg .raw .bmp
AllValidations.isImage('photo.webp'); // false

// Vídeos
AllValidations.isVideo('clip.mp4');   // true — .mp4 .wmv .avi .mkv .mov .flv e outros
AllValidations.isVideo('clip.webm'); // false

// Áudio
AllValidations.isAudio('song.mp3');   // true — .mp3 .wav .wma .amr .ogg
AllValidations.isAudio('song.flac'); // false

// Documentos
AllValidations.isPDF('doc.pdf');      // true
AllValidations.isTxt('notes.txt');    // true
AllValidations.isChm('help.chm');     // true
AllValidations.isVector('icon.svg');  // true
AllValidations.isHTML('page.html');   // true
```

---

## Documentos brasileiros

```dart
AllValidations.isCpf('529.982.247-25');       // true  (com ou sem máscara)
AllValidations.isCpf('52998224725');           // true
AllValidations.isCpf('111.111.111-11');        // false (dígitos iguais)
AllValidations.isCpf('000.000.000-00');        // false

AllValidations.isCnpj('11.222.333/0001-81');  // true  (numérico legado)
AllValidations.isCnpj('11222333000181');       // true
AllValidations.isCnpj('11.111.111/1111-11');  // false (dígitos iguais)

// CNPJ alfanumérico 2026 (IN RFB 2229/2024)
AllValidations.isCnpjAlphanumeric('AB.1CD.2EF/3GHI-45'); // true
AllValidations.isCnpjAlphanumeric('11222333000181');      // true (numérico também aceito)

AllValidations.isRG('12.345.678-9');           // true
AllValidations.isRG('12345678X');              // true (dígito final pode ser X)

AllValidations.isCnh('84718735264');           // true  (11 dígitos)
AllValidations.isCnh('00000000000');           // false (dígitos iguais)

AllValidations.isRenavam('95606520941');       // true  (9 a 11 dígitos, padded para 11)
AllValidations.isRenavam('956065209');         // true  (9 dígitos aceitos)

AllValidations.isPisPasep('12345678919');      // true  (11 dígitos)

AllValidations.isTituloEleitor('006000610949'); // true (12 dígitos, estado 01–28)

AllValidations.isValidBRZip('01310-100');      // true
AllValidations.isValidBRZip('01310100');       // true  (sem hífen, 8 dígitos)
AllValidations.isValidBRZip('01.310-100');     // true  (com ponto, aceito)
```

---

## Telefones brasileiros

`isBrazilianCellPhone` e `isBrazilianLandline` aceitam o prefixo `+55` ou `55` e o removem antes de validar. O DDD é validado contra a lista oficial de DDDs ativos.

```dart
// Celular — 11 dígitos (com DDD), primeiro dígito após DDD deve ser 9
AllValidations.isBrazilianCellPhone('(11) 99999-8877'); // true
AllValidations.isBrazilianCellPhone('11999998877');     // true
AllValidations.isBrazilianCellPhone('+5511999998877');  // true  (strip de +55)
AllValidations.isBrazilianCellPhone('5511999998877');   // true  (strip de 55)
AllValidations.isBrazilianCellPhone('(11) 3333-4444');  // false (fixo, não celular)
AllValidations.isBrazilianCellPhone('(00) 99999-8877'); // false (DDD 00 inválido)

// Fixo — 10 dígitos (com DDD), primeiro dígito após DDD deve ser 2, 3, 4 ou 5
AllValidations.isBrazilianLandline('(11) 3333-4444');  // true
AllValidations.isBrazilianLandline('1133334444');      // true
AllValidations.isBrazilianLandline('+551133334444');   // true  (strip de +55)
AllValidations.isBrazilianLandline('(11) 99999-8877'); // false (celular, não fixo)

// Validar DDD isolado
AllValidations.isValidDDD('11');  // true
AllValidations.isValidDDD('00');  // false
AllValidations.isValidDDD('20');  // false
```

---

## Outros

### Placas de veículo

Suporta formato antigo (`ABC-1234`) e Mercosul (`ABC1D23`):

```dart
AllValidations.isValidBrazilianLicensePlate('ABC-1234'); // true  (formato antigo)
AllValidations.isValidBrazilianLicensePlate('ABC1D23');  // true  (Mercosul)
AllValidations.isValidBrazilianLicensePlate('abc1D23');  // false (minúsculas)
```

> ⚠️ O formato Mercosul é `ABC1D23` — sem hífen. `ABC1-D23` retorna `false`.

### Cor hexadecimal

```dart
AllValidations.isValidHexColor('#FF5733');  // true
AllValidations.isValidHexColor('#FFF');     // true  (3 dígitos)
AllValidations.isValidHexColor('FF5733');   // false — '#' obrigatório aqui (diferente de isHexadecimal)
```

### EAN-13

Valida o dígito verificador pelo algoritmo oficial EAN:

```dart
AllValidations.isValidEAN13('7891234567890'); // true  (13 dígitos + DV correto)
AllValidations.isValidEAN13('1234567890123'); // false (DV inválido)
AllValidations.isValidEAN13('123456789');     // false (< 13 dígitos)
```

### Cartão de crédito (Luhn)

Aceita Visa, Mastercard, AmEx, Discover e JCB. Strip de não-dígitos antes de validar.

```dart
AllValidations.isCreditCard('4111111111111111');        // true  (Visa)
AllValidations.isCreditCard('4111-1111-1111-1111');    // true  (com hífens)
AllValidations.isCreditCard('1234567890123456');        // false
```

### Senhas

```dart
// Senha média: 6+ chars, combinação de maiúscula+minúscula, ou letra+número
AllValidations.isMediumPassword('Abc123');   // true
AllValidations.isMediumPassword('abc123');   // true
AllValidations.isMediumPassword('abc');      // false (< 6 chars)

// Senha forte: 8–99 chars, obriga maiúscula, minúscula, dígito E símbolo especial
AllValidations.isStrongPassword('Abc@1234');  // true
AllValidations.isStrongPassword('Abc1234');   // false (sem símbolo)
AllValidations.isStrongPassword('abc@1234'); // false (sem maiúscula)
```

Símbolos aceitos por `isStrongPassword`: `~!@#$%^&*()_\-+=|\\{}[\]:;<>?/`

### Palíndromo

Remove acentos, pontuação e espaços antes de comparar:

```dart
AllValidations.isPalindrome('ovo');         // true
AllValidations.isPalindrome('A man a plan a canal Panama'); // true
AllValidations.isPalindrome('Racecar');     // true
AllValidations.isPalindrome('hello');       // false
```

### Nickname

Começa e termina com letra ou dígito; aceita `.` e `_` no meio:

```dart
AllValidations.isNickname('user_name');  // true
AllValidations.isNickname('user.123');   // true
AllValidations.isNickname('_user');      // false (começa com _)
AllValidations.isNickname('ab');         // false (mínimo 3 chars)
```

### Nome sem caracteres especiais

```dart
AllValidations.isName('João Silva');  // true  — acentos são permitidos
AllValidations.isName('Jo@o');        // false — rejeita !@#<>?":_`~;[]|=+)(*&^%-
```

### Comparação numérica

```dart
AllValidations.isLowerThan(3, 5);   // true   (a < b)
AllValidations.isGreaterThan(5, 3); // true   (a > b)
AllValidations.isEqual(3, 3);       // true   (a == b)

AllValidations.isPhraseEqual('senha123', 'senha123'); // true
AllValidations.isPhraseEqual('senha123', 'senha456'); // false
```

---

## Manipulação de texto

```dart
// Remove tudo que não for letra (A-Za-z) ou dígito (0-9)
AllValidations.removeCharacters('000.000.000-00'); // '00000000000'
AllValidations.removeCharacters('AB.1CD/001-01');  // 'AB1CD00101'
// assert: valor não pode ser vazio

// Remove acentos
AllValidations.removeAccents('áãéí');  // 'aaei'
AllValidations.removeAccents('ção');   // 'cao'
```

> `removeCharacters` mantém letras maiúsculas e minúsculas além dos dígitos. Para extrair somente números, use `BrFormatter.stripCpf` / `stripCnpj` ou `.replaceAll(RegExp(r'\D'), '')` diretamente.

---

## Estado pelo DDD

> `getStateByDDD` é um método de **instância** — exige `AllValidations()`. Diferente de todos os outros que são `static`.

```dart
// ❌ Errado — não é static
// AllValidations.getStateByDDD('11');

// ✅ Correto
final av = AllValidations();
av.getStateByDDD('11');  // BrazilianState.SP
av.getStateByDDD('21');  // BrazilianState.RJ
av.getStateByDDD('61');  // BrazilianState.DF
av.getStateByDDD('99');  // BrazilianState.MA
av.getStateByDDD('00');  // BrazilianState.Unknown
```

Mapeamento resumido: 11–19 → SP · 21/22/24 → RJ · 27/28 → ES · 31–38 → MG · 41–46 → PR · 47–49 → SC · 51/53–55 → RS · 61 → DF · 62/64 → GO · 63 → TO · 65/66 → MT · 67 → MS · 68 → AC · 69 → RO · 71/73–75/77 → BA · 79 → SE · 81/87 → PE · 82 → AL · 83 → PB · 84 → RN · 85/88 → CE · 86/89 → PI · 91/93/94 → PA · 92/97 → AM · 95 → RR · 96 → AP · 98/99 → MA.

---

## Verificação de chaves em Mapas

`isMapExists` verifica se todas as chaves da lista existem no map e não são `null`. Loga via `dart:developer` cada chave encontrada ou ausente.

```dart
final map = {'status': 'ok', 'data': {'id': 1}};

AllValidations.isMapExists(key: ['status', 'data'], map: map); // true
AllValidations.isMapExists(key: ['status', 'user'], map: map); // false ('user' não existe)
AllValidations.isMapExists(key: ['status'], map: {'status': null}); // false (valor null)
```

---

## `validate*()` — validações com Result

Todos os métodos `validate*` retornam `Result<ValidationError, String>` em vez de `bool`. Em caso de sucesso, o `Right`/`Success` carrega o valor normalizado. Veja [Result.md](Result.md) para detalhes do tipo.

```dart
// CPF — sucesso retorna dígitos puros
AllValidations.validateCPF('529.982.247-25');
// Success('52998224725')

AllValidations.validateCPF('000.000.000-00');
// Failure(ValidationError(property: 'cpf', message: 'CPF inválido.'))

// property e message customizáveis
AllValidations.validateCPF('123',
  property: 'documento',
  message: 'Documento inválido',
);

// Email — sucesso retorna lowercased + trimmed
AllValidations.validateEmail('Carlos@Exemplo.COM');
// Success('carlos@exemplo.com')

// Placa — sucesso retorna toUpperCase()
AllValidations.validateLicensePlate('abc1D23');
// Success('ABC1D23')
```

### Tabela completa dos `validate*`

| Método | `property` padrão | Sucesso retorna |
|--------|--------------------|-----------------|
| `validateCPF` | `'cpf'` | dígitos puros |
| `validateCNPJ` | `'cnpj'` | dígitos puros |
| `validateEmail` | `'email'` | `trim().toLowerCase()` |
| `validateCEP` | `'cep'` | dígitos puros |
| `validateCellPhone` | `'celular'` | valor original |
| `validateLandline` | `'telefone'` | valor original |
| `validateCNH` | `'cnh'` | dígitos puros |
| `validateRENAVAM` | `'renavam'` | dígitos puros |
| `validatePIS` | `'pis'` | dígitos puros |
| `validateTituloEleitor` | `'tituloEleitor'` | dígitos puros |
| `validateRG` | `'rg'` | valor original |
| `validateLicensePlate` | `'placa'` | `toUpperCase()` |
| `validateURL` | `'url'` | valor original |
| `validateUUID` | `'uuid'` | valor original |
| `validateStrongPassword` | `'senha'` | valor original |
| `validateCreditCard` | `'cartao'` | dígitos puros |
| `validatePixKey` | `'chavePix'` | tipo como string |

---

## Chave PIX

`validatePixKey` retorna `Result` com o **tipo** da chave em caso de sucesso:

```dart
AllValidations.validatePixKey('529.982.247-25').fold(
  (err)  => print(err.message),
  (tipo) => print('Tipo: $tipo'),
);

AllValidations.validatePixKey('529.982.247-25');              // Success('CPF')
AllValidations.validatePixKey('+5511912345678');              // Success('Celular')
AllValidations.validatePixKey('user@example.com');            // Success('Email')
AllValidations.validatePixKey('123e4567-e89b-4d3a-a456-426614174000'); // Success('Chave Aleatória')
AllValidations.validatePixKey('12345678901');                 // Failure(...)
```

Regras de identificação por tipo:

| Tipo | Formato esperado |
|------|-----------------|
| `'CPF'` | CPF válido (com ou sem máscara) |
| `'Celular'` | `+55` + DDD (2 dígitos) + `9` + 8 dígitos → `+5511912345678` |
| `'Email'` | E-mail válido sem dígitos puros |
| `'Chave Aleatória'` | UUID v4 lowercase |

---

## Listas utilitárias

```dart
AllValidationsGetMonth.list;
// ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
//  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']

AllValidationsGetRegions.list;
// ['Norte', 'Nordeste', 'Centro-Oeste', 'Sudeste', 'Sul']

AllValidationsGetStates.list;
// ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
//  'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
//  'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO']

AllValidationsGetWeek.listDaysWeekAbvr;
// ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
```

---

## Referência rápida

| Método | Retorno | Observação |
|--------|---------|------------|
| `isNull(v)` | `bool` | |
| `isNum(s)` | `bool` | int ou double |
| `isNumericOnly(s)` | `bool` | somente dígitos |
| `isNumericFloat(s)` | `bool` | string vazia → `true` |
| `isAlphabetOnly(s)` | `bool` | sem espaço |
| `isBool(s)` | `bool` | `'true'` ou `'false'` |
| `isInt(s)` | `bool` | inteiro positivo ou negativo |
| `isLowercase(s)` | `bool` | |
| `isUppercase(s)` | `bool` | |
| `isBinary(s)` | `bool` | |
| `isJSON(s)` | `bool` | |
| `isEmail(s)` | `bool` | `+` permitido |
| `isURL(s)` | `bool` | protocolo obrigatório |
| `isMD5(s)` | `bool` | 32 hex |
| `isSHA1(s)` | `bool` | 40 hex |
| `isSHA256(s)` | `bool` | 64 hex |
| `isSSN(s)` | `bool` | formato EUA |
| `isHexadecimal(s)` | `bool` | `#` opcional |
| `isUUID(s, [v])` | `bool` | v3, v4, v5 ou 'all' |
| `isDateTime(s)` | `bool` | ISO8601/UTC |
| `isIPv4(s)` | `bool` | |
| `isIPv6(s)` | `bool` | |
| `isImage(s)` | `bool` | verifica extensão |
| `isVideo(s)` | `bool` | verifica extensão |
| `isAudio(s)` | `bool` | verifica extensão |
| `isPDF(s)` | `bool` | |
| `isTxt(s)` | `bool` | |
| `isChm(s)` | `bool` | |
| `isVector(s)` | `bool` | .svg |
| `isHTML(s)` | `bool` | |
| `isCpf(s)` | `bool` | aceita máscara |
| `isCnpj(s)` | `bool` | aceita máscara |
| `isCnpjAlphanumeric(s)` | `bool` | formato 2026 |
| `isRG(s)` | `bool` | dígito final pode ser X |
| `isCnh(s)` | `bool` | 11 dígitos |
| `isRenavam(s)` | `bool` | 9–11 dígitos |
| `isPisPasep(s)` | `bool` | 11 dígitos |
| `isTituloEleitor(s)` | `bool` | 12 dígitos |
| `isValidBRZip(s)` | `bool` | CEP |
| `isBrazilianCellPhone(s)` | `bool` | aceita +55 |
| `isBrazilianLandline(s)` | `bool` | aceita +55 |
| `isValidDDD(s)` | `bool` | |
| `isValidBrazilianLicensePlate(s)` | `bool` | antigo e Mercosul |
| `isValidHexColor(s)` | `bool` | `#` obrigatório |
| `isValidEAN13(s)` | `bool` | com DV |
| `isCreditCard(s)` | `bool` | Luhn |
| `isMediumPassword(s)` | `bool` | 6+ chars |
| `isStrongPassword(s)` | `bool` | 8+ chars + símbolo |
| `isPalindrome(s)` | `bool` | remove acentos/pontuação |
| `isNickname(s)` | `bool` | |
| `isName(s)` | `bool` | |
| `isLowerThan(a, b)` | `bool` | `a < b` |
| `isGreaterThan(a, b)` | `bool` | `a > b` |
| `isEqual(a, b)` | `bool` | `a == b` |
| `isPhraseEqual(s1, s2)` | `bool` | |
| `removeCharacters(s)` | `String` | mantém A-Z e 0-9 |
| `removeAccents(s)` | `String` | |
| `getStateByDDD(ddd)` | `BrazilianState` | **instância**, não static |
| `isMapExists({key, map})` | `bool` | |
| `validate*` | `Result<ValidationError, String>` | ver tabela acima |

---

← [Voltar ao README](../README.md)
