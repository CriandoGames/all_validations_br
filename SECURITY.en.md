[🇧🇷 Português](SECURITY.md) | 🇺🇸 English

# Security policy

The prepared line is `4.6.x`; until it is published, the latest stable version on pub.dev remains the public reference. The aggregator combines modules with different risk profiles; cryptographic reports should identify `all_crypto`, and logging reports should state whether sensitive data was exposed.

Report vulnerabilities privately through the repository's **Security
advisories** feature, when enabled, or another private channel confirmed by the
maintainer. Verify that the channel is operational before publication.

Do not open a public issue containing an exploit, key, token, real CPF/CNPJ, card number, or production payload. Include the version, platform, impact, and a sanitized minimal reproduction. Maintainers will acknowledge the report and coordinate remediation and disclosure; timing depends on severity and maintainer capacity.

`HelperUtil.decodeJWT` only parses payloads and does not authenticate signatures. The legacy password hash in `HelperUtil` should not be adopted by new systems. Use dedicated libraries and appropriate password-derivation algorithms. Also read `all_crypto`'s bilingual security policies.

The legacy crypto payload had no real version and its serialization included
the key itself. Use `AllCrypto` with the v2 `CryptEnvelope` and an external key
for new data. `EncryptedPayload.fromJson`/`fromBase64` remain only for
migration; treat a key from a legacy payload that circulated as compromised.

`HelperUtil.removeHtmlTags` is not an XSS sanitizer. The legacy generators with UUID v3/v5 bits use a simplified digest and are not interoperable with the normative MD5/SHA-1 algorithm; use a specialized implementation when that compatibility is required. PIX/document masks reduce visual exposure but do not anonymize or authorize storage of real data.
