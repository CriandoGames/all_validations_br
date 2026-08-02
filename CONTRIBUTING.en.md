# Contributing

Create changes from `main` in a focused branch. Use Dart 3.0+ and Flutter 3.0+, keep implementation in the responsible specialized package, and preserve historical imports through re-exports when possible.

Before submitting a pull request, run the package boundary checker, formatting, analyzer, tests, documentation generation, and publication dry-runs. A new validation or mask must include positive, negative, boundary, regression, and integration tests. Never add path dependencies to a publishable `pubspec.yaml`; local development uses `pubspec_overrides.yaml`.

Report security concerns through the private channel documented in the relevant package policy. Do not include credentials, personal data, tokens, keys, or production payloads in issues or fixtures.
