# Ecosystem architecture

Implementations were split into five sibling projects next to `all_validations_br` under the `E:/pro/all` working directory. This layout replaces the original `packages/` suggestion with explicit maintainer authorization and allows each package to be versioned and published independently.

```text
all_br_forms ──────────> all_br_validations ──────> all_result

all_validations_br ────> all_br_forms
all_validations_br ────> all_br_validations
all_validations_br ────> all_crypto
all_validations_br ────> all_logger
all_validations_br ────> all_result
```

`all_crypto`, `all_logger`, and `all_result` are independent pure-Dart packages. `all_br_validations` is pure Dart and uses `all_result` for `ValidationNotifiable` and `ValidationResult`. `all_br_forms` requires Flutter and integrates with `all_br_validations` without duplicating rules. The aggregator depends on all modules and retains only barrels, compatibility tests, documentation, an integrated example, and the legacy `HelperUtil`.

Publishable manifests use hosted versions. Publication-excluded `pubspec_overrides.yaml` files connect sibling directories for local development and verification.

## Responsibilities and boundaries

| Package | Runtime | Ecosystem dependency | Public responsibility |
|---|---|---|---|
| `all_result` | Dart | none | `Result<F, S>`, composition, and asynchronous operations |
| `all_crypto` | Dart | none | ciphers, hashes, MACs, and externally keyed v2 `CryptEnvelope` values |
| `all_logger` | Dart | none | levels, filters, printers, and outputs |
| `all_br_validations` | Dart | `all_result` | Brazilian rules, formatters, `BrZod`, and `Contract` |
| `all_br_forms` | Flutter | `all_br_validations` | Flutter input masks and integration |
| `all_validations_br` | Flutter | all five modules | maintained facade, compatibility, and `HelperUtil` |

Specialized packages never import the aggregator. The four pure-Dart packages do not import Flutter. Validation rules belong in `all_br_validations`; masks may shape keystrokes but do not copy CPF/CNPJ algorithms. The root contains no extracted implementations: its barrels re-export the responsible modules.

## Public surface and compatibility

The main barrel remains available and is not deprecated. Historical topic imports continue to compile, but point to focused entry points where that prevents accidental surface expansion. `br_zod.dart`, `br_logger.dart`, `validation.dart`, and `regions_validations.dart` provide actionable migration diagnostics; no removal version has been approved.

`HelperUtil` remains only in the aggregator because it combines text, dates, platform, JWT, PIX, UUID, and old password helpers. Creating an `all_utils` package would merely relocate that lack of cohesion. Migration is method-by-method, and legacy risks are covered by the security policy.

At the crypto boundary, `AllCrypto` and the v2 `CryptEnvelope` are the
recommended path: the envelope is versioned and never contains the key.
`EncryptedPayload` keeps decoding the unversioned historical format; only its
key-embedding serialization paths remain deprecated for migration.

## Development and CI

Every publishable manifest uses hosted constraints without `path`. Local overrides, always excluded from archives, connect sibling packages before publication. Global CI checks inventory, boundaries, cycles, imports, documentation, examples, secrets, analyzer, tests with coverage, dartdoc, and six dry-runs. All five repositories now exist, but they must receive the final local state before the global checkout can reproduce this validation.

`all_observer` appears exclusively in the `example/` application to demonstrate reactive rebuilding of an integrated result. It is neither architecture nor a package runtime dependency; its controller, observables, computeds, lints, and disposal remain confined to the example.
