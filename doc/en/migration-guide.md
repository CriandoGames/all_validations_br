# Migrating from 4.5.2 to 5.0.0

Version 5 turns the monolithic package into an aggregator toolkit. The
implementations now live in five specialized packages, while
`all_validations_br` preserves its public facade, historical imports, and
`HelperUtil`.

## Recommended migration

Applications that only use public APIs can first change the version without
changing their import:

```yaml
dependencies:
  all_validations_br: ^5.0.0
```

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

Run `flutter pub get`, `flutter analyze`, and your tests. All five specialized
dependencies are installed automatically.

## What remains compatible

- The `all_validations_br.dart` barrel and its public symbols.
- The `validation.dart`, `br_zod.dart`, `br_logger.dart`, `crypt.dart`, and
  `regions_validations.dart` imports.
- `AllValidations`, `BrZod`, `Contract`, masks, formatters, models, `Result`,
  logger, and historical crypto algorithms.
- `HelperUtil`, including deprecated methods required during migration.
- Reading and decrypting historical crypto payloads.

The historical validation, BrZod, logger, and regions imports now emit a
deprecation diagnostic. They have no removal schedule in this release.

## Breaking changes and behavioral impact

### Private deep imports

Imports under `package:all_validations_br/src/...` are not preserved. Replace
them with a public barrel or the responsible specialized package:

| Before | Recommended replacement |
|---|---|
| `all_validations_br/src/validator/...` | `package:all_br_validations/all_br_validations.dart` |
| `all_validations_br/src/masks/...` | `package:all_br_forms/all_br_forms.dart` |
| `all_validations_br/src/result/...` | `package:all_result/all_result.dart` |
| `all_validations_br/src/logger/...` | `package:all_logger/all_logger.dart` |
| `all_validations_br/src/crypt/...` | `package:all_crypto/all_crypto.dart` |

### Release logging

In 4.5.2, `BrDevelopmentFilter` allowed `warning` and higher levels in release
builds. In 5.0.0, `BrLogger()` blocks every release log by default. Explicitly
enable production errors when required:

```dart
final log = BrLogger(
  filter: const BrDevelopmentFilter(
    allowInRelease: true,
    minLevelProduction: BrLogLevel.error,
  ),
);
```

Printers also show icons by default. If tests, files, or parsers depend on the
exact formatted text, set `showIcons: false`.

### Cryptography

`CryptUtil` and `EncryptedPayload` remain available for reading old data. The
shortcuts that serialize the key next to ciphertext are deprecated. Use
`AllCrypto`/`CryptEnvelope` for new data and keep keys in a keychain, KMS, or
external vault.

## Optional modular migration

New projects may install only the module they need. For a gradual migration:

1. Identify the symbols in use.
2. Add the package shown in the README table.
3. Change only the import.
4. Run the analyzer and tests.
5. Remove the aggregator when no imports reference it.

`HelperUtil` has no single replacement. Migrate each method to the specialized
API indicated by its reference documentation.
