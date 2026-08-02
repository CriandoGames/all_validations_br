# Choosing a package

| Need | Package |
|---|---|
| CPF, CNPJ, documents, email, URL, dates, `BrZod`, or `Contract` | `all_br_validations` |
| `TextInputFormatter`, masks, and Flutter fields | `all_br_forms` |
| Ciphers, hashes, HMAC, and cryptographic payloads | `all_crypto` |
| Log levels, filters, printers, and outputs | `all_logger` |
| `Result<F, S>`, composition, and asynchronous operations | `all_result` |
| Gradual migration or every feature | `all_validations_br` |

Pure Dart projects should not install the aggregator or `all_br_forms`. A focused module reduces the dependency graph and makes ownership explicit. Use the aggregator when compatibility with existing imports matters more than graph size.

`all_br_validations` is the public core for Brazilian validation. Applications
and libraries can adopt it directly as a foundation for domain rules,
contracts, schemas, and formatting. Its API follows SemVer, has no Flutter
dependency, and provides canonical rules covered by tests. Other packages can
therefore build on it without depending on the compatibility aggregator.

This guarantee covers the documented software contract. Validating a CPF, CNPJ,
or other value locally does not prove identity, ownership, or existence in an
official source.

## Quick decision

- Start with the focused module for a new project.
- Use `all_validations_br` when an application already relies on several historical imports or needs gradual migration.
- Use `all_br_forms` only in the Flutter layer; validate the final value with `all_br_validations` when semantic rules apply.
- Do not install `all_crypto` for password storage; choose an appropriate password-derivation library.
- In `all_crypto`, prefer `AllCrypto` with the v2 `CryptEnvelope` and keep the
  key outside the payload. Use `EncryptedPayload.fromJson`/`fromBase64` only
  to read legacy data.
- Do not install `all_logger` expecting redaction: sanitize CPF, tokens, cards, and keys before logging.

## Focused imports

```dart
import 'package:all_result/all_result.dart';
import 'package:all_logger/all_logger.dart';
import 'package:all_br_validations/br_zod.dart';
import 'package:all_br_validations/validation.dart';
```

`HelperUtil` has no single replacement package. Read its reference and migrate only the method in use. The reactive application under `example/` uses `all_observer` only to demonstrate UI updates; ecosystem consumers do not need that dependency.
