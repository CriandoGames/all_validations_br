/// Barrel de compatibilidade do módulo de criptografia.
///
/// Novos projetos devem importar `package:all_crypto/all_crypto.dart`. Este
/// entry point continua mantido e reexporta a API completa, inclusive
/// [AllCrypto] e [CryptEnvelope].
///
/// ```dart
/// import 'package:all_validations_br/crypt.dart';
///
/// final key = AllCrypto.generateKey();
/// final envelope = AllCrypto.encryptText('segredo', key: key);
/// final encoded = envelope.toBase64(); // nunca inclui a chave
/// final plain = AllCrypto.decryptText(
///   CryptEnvelope.fromBase64(encoded),
///   key: key,
/// );
/// ```
///
/// ## O que é exportado
///
/// | Símbolo | Descrição |
/// |---------|-----------|
/// | [AllCrypto] | Fachada recomendada com chave externa |
/// | [CryptEnvelope] | Payload v2 versionado que nunca serializa a chave |
/// | [CryptUtil] | API histórica; serialização Base64 legada está depreciada |
/// | [AesGcm] | AES-GCM direto (NIST SP 800-38D) |
/// | [AesCbc] | AES-CBC + PKCS#7 direto (NIST SP 800-38A) |
/// | [AesCtr] | AES-CTR direto (NIST SP 800-38A) |
/// | [sha256] | Hash SHA-256 (FIPS 180-4) |
/// | [hmacSha256] / [hmacEqual] | HMAC-SHA256 (RFC 2104) |
/// | [EncryptedPayload] | Decoder/modelo legado para compatibilidade |
/// | [CryptException] | Exceção de autenticação falha |
library all_validations_br.crypt;

export 'package:all_crypto/all_crypto.dart';
