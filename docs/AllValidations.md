# AllValidations — Validações Brasileiras

Classe principal de validações. Cobre CPF, CNPJ, CNH, RENAVAM, PIS/PASEP, Título de Eleitor, chaves PIX, telefones, CEP, placas, EAN-13, cores hex, UUIDs, e-mails, URLs e muito mais.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Verificação de tipos e formatos

```dart
AllValidations.isNull(value);
AllValidations.isNum('42');          // true
AllValidations.isNumericOnly('123'); // true
AllValidations.isNumericFloat('1.5'); // true
AllValidations.isAlphabetOnly('abc'); // true
AllValidations.isLowercase('abc');    // true
AllValidations.isUppercase('ABC');    // true
AllValidations.isUUID('550e8400-e29b-41d4-a716-446655440000'); // true
AllValidations.isJSON('{"key":"val"}'); // true
AllValidations.isHexadecimal('FF');    // true
AllValidations.isEmail('user@example.com'); // true
AllValidations.isURL('https://flutter.dev'); // true
```

---

## Documentos brasileiros

```dart
AllValidations.isCpf('529.982.247-25');   // true
AllValidations.isCnpj('11.222.333/0001-81'); // true
AllValidations.isCnpjAlphanumeric('AB.1CD.2EF/3GHI-45'); // true (novo 2026)
AllValidations.isRG('12.345.678-9');       // true
AllValidations.isCnh('84718735264');       // true
AllValidations.isRenavam('95606520941');   // true
AllValidations.isPisPasep('12345678919'); // true
AllValidations.isTituloEleitor('006000610949'); // true
AllValidations.isValidBRZip('01310-100'); // true
```

---

## Telefones

```dart
AllValidations.isBrazilianCellPhone('(11) 99999-8877'); // true
AllValidations.isBrazilianLandline('(11) 3333-4444');   // true
```

---

## Outros

```dart
AllValidations.isLeapYear(2024);  // true
AllValidations.isValidBrazilianLicensePlate('ABC-1D23'); // true
AllValidations.isValidEAN13('7891234567890'); // true
AllValidations.isValidHexColor('#FF5733');    // true
```

---

## Manipulação de texto

```dart
AllValidations.removeCharacters('000.000.000-00'); // '00000000000'
AllValidations.removeNonNumeric('abc123');         // '123'
AllValidations.removeAccents('áãé');               // 'aae'
AllValidations.isPhraseEqual('123', '123');        // true
```

---

## Chaves PIX

```dart
// Valida e retorna o tipo: 'CPF', 'Celular', 'Email', 'Chave Aleatória', ou null
HelperUtil.validatePixKey('992.864.791-74'); // 'CPF'
HelperUtil.validatePixKey('+5511912345678'); // 'Celular'
HelperUtil.validatePixKey('user@example.com'); // 'Email'
HelperUtil.validatePixKey('123e4567-e89b-4d3a-a456-426614174000'); // 'Chave Aleatória'
HelperUtil.validatePixKey('12345678901'); // null

// Mascaramento
HelperUtil.maskPixKey('99286479174');       // '992.***.***-74'
HelperUtil.maskPixKey('+5511912345678');    // '+5511*****678'
HelperUtil.maskPixKey('user@example.com'); // 'us**@example.com'
```

---

## Estado pelo DDD

```dart
AllValidations.getStateByDDD('11'); // BrazilianState.SP
AllValidations.getStateByDDD('21'); // BrazilianState.RJ
```

---

## Verificação de chaves em Mapas JSON

```dart
Map<String, dynamic> map1 = {"status": "success", "message": "ok"};
bool existe = AllValidations.isMapExists(map: map1, key: ['status']); // true
```

---

## `validate*()` — validações com Result

Para validação retornando `Result<ValidationError, T>` em vez de `bool`:

```dart
AllValidations.validateCPF('529.982.247-25');
// Success('52998224725')

AllValidations.validateEmail('Carlos@Exemplo.COM');
// Success('carlos@exemplo.com')

AllValidations.validateCPF('000.000.000-00');
// Failure(ValidationError(property: 'cpf', message: 'CPF inválido.'))
```

Veja a lista completa em [Result.md](Result.md#allvalidationsvalidate--validações-pontuais-com-result).

---

## Listas utilitárias

```dart
AllValidationsGetMonth.list;      // ['Janeiro', 'Fevereiro', ...]
AllValidationsGetRegions.list;    // ['Norte', 'Nordeste', ...]
AllValidationsGetStates.list;     // ['SP', 'RJ', 'MG', ...]
AllValidationsGetWeek.listDaysWeekAbvr; // ['Seg', 'Ter', 'Qua', ...]
```

---

← [Voltar ao README](../README.md)
