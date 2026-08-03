# HelperUtil — Legacy General-Purpose Utilities

`HelperUtil` groups historical text, date, UUID, JWT, PIX, password, and
platform helpers that do not form one cohesive specialized package. It remains
in the maintained `all_validations_br` aggregator for compatibility; no
`all_utils` package was created.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

## Text manipulation

```dart
HelperUtil.countWords('Flutter is productive'); // 3
HelperUtil.countWords('');                      // 0

HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>');
// Hello World

HelperUtil.capitalizeWords('hello dart world');
// Hello Dart World
```

`removeHtmlTags` is a presentation helper based on the implementation's tag
pattern. It is not an HTML sanitizer and must not be used as an XSS security
boundary. `capitalizeWords` follows simple word/case rules rather than full
locale-aware title casing.

## Strings and random values

```dart
HelperUtil.removeNonNumeric('(11) 99999-8877'); // 11999998877
HelperUtil.removeNonNumeric('R\$ 1.234,56');    // 123456

final token = HelperUtil.generateRandomString(16);
final die = HelperUtil.generateRandomInt(1, 6);
```

`generateRandomInt(min, max)` includes both endpoints. Invalid bounds follow
the implementation's argument contract. Random strings/integers are convenience
values and are not documented as cryptographically secure secrets, password
salts, session tokens, or keys.

## Mathematics

```dart
HelperUtil.calculatePercentage(25, 200); // 12.5
```

The method calculates `value / total * 100` and throws `ArgumentError` when
`total` is zero.

## Dates and times

```dart
final local = HelperUtil.convertUtcToLocal(
  DateTime.utc(2026, 6, 27, 12),
);
final utc = HelperUtil.convertLocalToUtc(
  DateTime(2026, 6, 27, 9),
);

HelperUtil.daysBetween(
  DateTime(2026, 1, 1),
  DateTime(2026, 12, 31),
); // 364

HelperUtil.businessDaysBetween(
  DateTime(2026, 6, 1),
  DateTime(2026, 6, 30),
); // weekdays only; no holiday calendar
```

`toLocal`/`toUtc` use Dart's platform time-zone behavior. `daysBetween` uses
`Duration.inDays`. `businessDaysBetween` excludes Saturday and Sunday only; it
does not know national, state, municipal, or organization holidays.

```dart
HelperUtil.isLeapYear(2024); // true
HelperUtil.isLeapYear(1900); // false
HelperUtil.isLeapYear(2000); // true
```

## Date validity, age, and adulthood

`isValidDate` accepts strict `dd/MM/yyyy` or `yyyy-MM-dd` and rejects impossible
calendar dates.

```dart
HelperUtil.isValidDate('29/02/2024'); // true
HelperUtil.isValidDate('29/02/2025'); // false
HelperUtil.isValidDate('2026-06-15'); // true
```

```dart
final age = HelperUtil.calculateAge(DateTime(1990, 5, 15));
final adult = HelperUtil.isAdult(
  DateTime(2005, 1, 1),
  minAge: 21,
);
```

Both use the current local date. Results therefore depend on the day the code
runs and the platform clock. The historical implementation does not reject a
future birth date and may return a negative age; validate input at the
application boundary. These helpers do not replace legal age policy for a
specific jurisdiction.

## UUID

```dart
final random = HelperUtil.generateUUIDv4();

final v3 = HelperUtil.generateUUIDv3(
  '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
  'entity-name',
);

final v5 = HelperUtil.generateUUIDv5(
  '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
  'entity-name',
);
```

The v3/v5 compatibility methods are deterministic for the same positional
namespace/name pair and set the corresponding version bits. Their historical
implementation uses a simplified custom digest: it does not calculate the
normative UUID MD5/SHA-1 algorithms. Preserve it only to reproduce historical
identifiers; use a specialized, vector-tested library for interoperable UUID
v3/v5. These values are identifiers, not authentication tokens.

## JWT inspection

These helpers decode JWT payloads but **do not validate a signature, issuer,
audience, algorithm, or trust**. Use a JWT verification library and trusted key
material at the security boundary.

```dart
final payload = HelperUtil.decodeJWT(token); // Map or null
final expired = HelperUtil.isJwtExpired(token);
final expiredAtReference = HelperUtil.isJwtExpired(
  token,
  referenceTime: DateTime.utc(2030, 1, 1),
);
final hasRole = HelperUtil.hasJwtClaim(token, 'role');
final role = HelperUtil.getJwtClaim(token, 'role');
```

`isJwtExpired` accepts an `int`, finite `num`, or integer string `exp` value.
Missing, malformed, or unsupported values are treated as expired without
throwing. The comparison uses `>=`, so a token expires exactly at the `exp`
instant. `referenceTime` is optional and enables deterministic tests. None of
these methods validates a signature or makes an untrusted claim authoritative.

## Legacy password helpers

`encryptPassword` and `validatePassword` are compatibility methods based on a
custom simple hash. Despite the historical name, this is not encryption and is
not suitable for production password storage.

```dart
final stored = HelperUtil.encryptPassword(
  'demo-password',
  'demo-application-key',
  'demo-salt',
);

final valid = HelperUtil.validatePassword(
  'demo-password',
  'demo-application-key',
  stored,
);
```

Use a dedicated reviewed password KDF such as Argon2id, bcrypt, scrypt, or
PBKDF2 with platform-appropriate parameters. Reversible encryption is not a
substitute for password hashing. Do not use `generateRandomString` as a secret
salt unless its entropy source has been independently reviewed for that use.

## PIX keys

Use `AllValidations.validatePixKey` as the single validation and
classification source. A successful result contains a `PixKeyType`:

```dart
AllValidations.validatePixKey('992.864.791-74').successValue;
// PixKeyType.cpf

AllValidations.validatePixKey('12ABC34501DE35').successValue;
// PixKeyType.cnpj
```

Validation checks local shape/check digits. It does not contact BACEN or prove
registration/ownership.

`maskPixKey` produces a presentation-safe partial value for recognized shapes:

```dart
HelperUtil.maskPixKey('99286479174');
HelperUtil.maskPixKey('12.345.678/0001-95'); // 12.***.***/****-95
HelperUtil.maskPixKey('12ABC34501DE35'); // 12.***.***/****-35
HelperUtil.maskPixKey('+5511912345678');
HelperUtil.maskPixKey('user@example.com');
HelperUtil.maskPixKey('unknown non-empty value'); // ***
HelperUtil.maskPixKey(''); // empty
```

Unknown non-empty values are never returned in clear text; the safe fallback is
`***`, while an empty input remains empty. Masking reduces display exposure but
does not anonymize, encrypt, or authorize storage of a real key.
`maskPixKey` delegates classification to `AllValidations.validatePixKey`; it
does not maintain a second validation implementation.

## Platform information

```dart
final info = HelperUtil.getDeviceInfo();
print(info['platform']);
print(info['isWeb']);
```

The map reports the Flutter foundation target platform and Web flag used by the
legacy aggregator. It does not provide hardware identifiers, OS version,
device model, security posture, or a stable fingerprint.

## Deprecated formatting methods

| Deprecated API | Replacement |
|---|---|
| `formatText(input, 'cpf')` | `BrFormatter.formatCpf(input)` |
| `formatText(input, 'cnpj')` | `BrFormatter.formatCnpj(input)` |
| `formatText(input, 'celular')` | `BrFormatter.formatPhone(input)` |
| `formatText(input, 'dinheiro')` | parse intentionally, then `BrFormatter.formatCurrency` |
| `formatText(input, 'data')` | parse intentionally, then `BrData.format` |
| `formatCurrency(value)` | `BrFormatter.formatCurrency(value)` |

These methods remain for source compatibility. No removal version has been
approved. New code should use the focused formatter APIs from
`all_br_validations`.

## Quick reference

| Method | Return | Scope |
|---|---|---|
| `countWords` | `int` | simple word count |
| `removeHtmlTags` | `String` | presentation cleanup, not sanitization |
| `capitalizeWords` | `String` | simple capitalization |
| `removeNonNumeric` | `String` | ASCII digit extraction |
| `generateRandomString` | `String` | convenience randomness |
| `generateRandomInt` | `int` | inclusive range |
| `calculatePercentage` | `double` | percentage |
| `convertUtcToLocal` / `convertLocalToUtc` | `DateTime` | platform conversion |
| `daysBetween` | `int` | elapsed whole days |
| `businessDaysBetween` | `int` | weekdays, no holidays |
| `isLeapYear` / `isValidDate` | `bool` | calendar checks |
| `calculateAge` / `isAdult` | `int` / `bool` | current-date calculation |
| `generateUUIDv4/v3/v5` | `String` | identifiers |
| `decodeJWT` | `Map<String, dynamic>?` | unverified payload decode |
| `isJwtExpired` / `hasJwtClaim` | `bool` | unverified claim inspection |
| `getJwtClaim` | `dynamic` | unverified claim value |
| `encryptPassword` / `validatePassword` | `String` / `bool` | legacy low-risk compatibility |
| `validatePixKey` | `String?` | local type/shape label |
| `maskPixKey` | `String` | partial presentation |
| `getDeviceInfo` | `Map<String, dynamic>` | platform/isWeb only |

See the [migration guide](migration-guide.md) and
[security policy](../../SECURITY.en.md).
