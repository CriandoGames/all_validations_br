# all_validations_br

[🇧🇷 Português](https://github.com/CriandoGames/all_validations_br/blob/main/README.md) | 🇺🇸 English

[![pub package](https://img.shields.io/pub/v/all_validations_br.svg)](https://pub.dev/packages/all_validations_br)
[![CI](https://github.com/CriandoGames/all_validations_br/actions/workflows/ecosystem-ci.yml/badge.svg)](https://github.com/CriandoGames/all_validations_br/actions/workflows/ecosystem-ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE)

The complete All ecosystem toolkit for Brazilian Flutter applications:
validations, forms, `Result`, logging, and cryptography through one dependency,
while preserving the package's historical imports.

![all_validations_br toolkit](https://raw.githubusercontent.com/CriandoGames/all_validations_br/main/documentation/images/hero.png)

## Why use it

`all_validations_br` is the entry point for Flutter projects that need several
ecosystem modules. A single import provides Brazilian rules, masks, result
contracts, structured logging, and authenticated encryption.

- One dependency for all five official modules.
- Specialized APIs maintained as independent, testable packages.
- Compatibility for projects already using historical imports.
- A gradual migration path toward smaller dependency graphs.
- An integrated Flutter example with realistic scenarios.

## What's included

| Area | Included package | Main capabilities |
|---|---|---|
| Validations | [`all_br_validations`](https://pub.dev/packages/all_br_validations) `^1.0.1` | CPF, CNPJ, documents, `BrZod`, `Contract`, formatters, and Brazilian models |
| Forms | [`all_br_forms`](https://pub.dev/packages/all_br_forms) `^1.0.0` | 24 Flutter masks and `TextInputFormatter`s |
| Results | [`all_result`](https://pub.dev/packages/all_result) `^1.0.0` | `Result<F, S>` and sync/async composition |
| Logging | [`all_logger`](https://pub.dev/packages/all_logger) `^1.0.1` | levels, filters, colors, printers, and outputs |
| Cryptography | [`all_crypto`](https://pub.dev/packages/all_crypto) `^1.0.1` | ChaCha20-Poly1305, AES-GCM, SHA-256, HMAC, and v2 envelopes |
| Compatibility | included in the aggregator | `HelperUtil` and historical barrels |

These dependencies are installed automatically. You do not need to declare
them separately when using the toolkit.

## Installing

```yaml
dependencies:
  all_validations_br: ^5.0.1
```

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

## Quick usage

### Validate and format Brazilian data

```dart
final validCpf = AllValidations.isCpf('529.982.247-25');
final document = BrFormatter.formatCpf('52998224725');

final validator = BrZod().required().cpf().build;
final message = validator('529.982.247-25'); // null: valid value
```

### Mask and validate the same field

```dart
TextFormField(
  inputFormatters: const [PhoneMask()],
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: BrZod().required().phone().build,
)
```

The mask controls typing; `BrZod` validates the value. A mask alone does not
verify check digits or domain rules.

### Explicit failures with Result

```dart
Result<String, String> validateCustomer(String cpf) {
  final error = BrZod().required().cpf().build(cpf);
  return error == null
      ? Result.success<String, String>(cpf)
      : Result.failure<String, String>(error);
}

final message = validateCustomer('529.982.247-25').fold(
  (failure) => failure,
  (value) => 'Accepted CPF: $value',
);
```

### Environment-controlled logging

```dart
final log = BrLogger(tag: 'Checkout');
log.info('order validated');
log.warning('payment gateway latency is high');
log.dispose();
```

The default filter blocks logs in release builds. Production logging must be
enabled explicitly. The logger does not redact sensitive data automatically.

### Authenticated encryption with an external key

```dart
final key = AllCrypto.generateKey(); // store in a keychain, KMS, or vault
final envelope = AllCrypto.encryptText('secret', key: key);
final token = envelope.toBase64(); // never contains the key

final restored = CryptEnvelope.fromBase64(token);
final plaintext = AllCrypto.decryptText(restored, key: key);
```

For new data, prefer `AllCrypto` and `CryptEnvelope`. The package does not
provide a key vault, password KDF, TLS, or user authentication.

## Complete toolkit or separate modules?

Use `all_validations_br` when a Flutter application uses several modules, or
when compatibility is required during migration. For new projects using only
one area, install the specialized package directly. Pure Dart projects should
not install this aggregator because `all_br_forms` adds Flutter to the
dependency graph.

| If you only need... | Install directly |
|---|---|
| Brazilian validations and rules | `all_br_validations` |
| Flutter masks | `all_br_forms` |
| typed failures | `all_result` |
| logging | `all_logger` |
| cryptography and hashes | `all_crypto` |

## Compatibility

The main barrel and the historical `validation.dart`, `br_zod.dart`,
`br_logger.dart`, `crypt.dart`, and `regions_validations.dart` imports remain
available. `HelperUtil` stays in the aggregator for compatibility; prefer the
specialized APIs in new code.

In 5.0.1, `HelperUtil` recognizes and masks CNPJ PIX keys; unknown non-empty
values are masked as `***`. `isJwtExpired` treats missing or invalid `exp` as
expired, accepts an optional `referenceTime`, and expires a token exactly at
the `exp` instant.

When migrating from 4.5.2, deep imports under `src/` must be replaced, and the
logger is now fully disabled in release builds by default. See the
[migration guide](https://github.com/CriandoGames/all_validations_br/blob/main/doc/en/migration-guide.md).

## Integrated example

The [example application](https://github.com/CriandoGames/all_validations_br/tree/main/example)
demonstrates validations, masks, utilities, and cryptography. Run it with:

```bash
cd example
flutter pub get
flutter run
```

## Documentation

- [Ecosystem architecture](https://github.com/CriandoGames/all_validations_br/blob/main/doc/en/architecture.md)
- [Choosing a package](https://github.com/CriandoGames/all_validations_br/blob/main/doc/en/package-selection.md)
- [Migration guide](https://github.com/CriandoGames/all_validations_br/blob/main/doc/en/migration-guide.md)
- [HelperUtil reference](https://github.com/CriandoGames/all_validations_br/blob/main/doc/en/helper-util.md)
- [Security policy](https://github.com/CriandoGames/all_validations_br/blob/main/SECURITY.en.md)
- [Contributing](https://github.com/CriandoGames/all_validations_br/blob/main/CONTRIBUTING.en.md)

[MIT](https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE) licensed.
