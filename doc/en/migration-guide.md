# Migration guide

## No immediate source change

Upgrade to `all_validations_br: ^5.0.0` and keep the current import. Historical public APIs remain re-exported and covered by compilation tests.

## Modular migration

1. Identify the symbols your project uses.
2. Add the responsible package at the version shown in the README table.
3. Change only the import.
4. Run the analyzer and tests.
5. Remove the aggregator once no legacy imports remain.

| Before | After |
|---|---|
| `all_validations_br.dart` for `AllValidations` | `all_br_validations.dart` |
| `all_validations_br.dart` for `CpfMask` | `all_br_forms.dart` |
| `crypt.dart` | `all_crypto.dart` |
| `br_logger.dart` | `all_logger.dart` |
| `all_validations_br.dart` for `Result` | `all_result.dart` |

## Crypto: legacy payload to v2 envelope

Historical `EncryptedPayload` values are unversioned and their serialization
includes the key. The old barrel can still read them, but new data must not use
that format.

```dart
final legacy = EncryptedPayload.fromBase64(oldToken);
final migrated = AllCrypto.migrateLegacy(legacy);

await saveEnvelope(migrated.envelope.toBase64());
await saveKeyInVault(migrated.key);
```

`CryptEnvelope.currentVersion` is `2`; missing, future, or unknown versions are
rejected. If a legacy token left trusted storage, treat its embedded key as
compromised and re-encrypt with a new key. For new data, call
`AllCrypto.encryptText(..., key:)` directly.

`HelperUtil` has no single replacement. Move PIX validation to `all_br_validations`, formatting to `BrFormatter`, crypto/hash work to `all_crypto`, and JWT work to a library that verifies signatures. Other helpers remain compatible in the aggregator until a future major-version decision.

Historical phone behavior is preserved: `BrZod.phone()` accepts a raw 8- or 9-digit subscriber number as well as DDD formats, while `Contract.isPhoneNumber` requires a canonical rule with DDD. A dedicated test protects this difference from a silent contract change.
