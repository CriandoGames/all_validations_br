/// Módulo de criptografia do `all_validations_br`.
///
/// Importação separada para projetos que usam **apenas** o módulo crypt,
/// sem trazer validações, máscaras ou formatadores.
///
/// ```dart
/// import 'package:all_validations_br/crypt.dart';
///
/// final key     = CryptUtil.generateKey();
/// final payload = CryptUtil.encryptAesGcm(utf8.encode('segredo'), key: key);
/// final plain   = CryptUtil.decryptAny(payload);
/// ```
///
/// ## O que é exportado
///
/// | Símbolo | Descrição |
/// |---------|-----------|
/// | [CryptUtil] | API unificada — encrypt/decrypt para todos os algoritmos |
/// | [AesGcm] | AES-GCM direto (NIST SP 800-38D) |
/// | [AesCbc] | AES-CBC + PKCS#7 direto (NIST SP 800-38A) |
/// | [AesCtr] | AES-CTR direto (NIST SP 800-38A) |
/// | [sha256] | Hash SHA-256 (FIPS 180-4) |
/// | [hmacSha256] / [hmacEqual] | HMAC-SHA256 (RFC 2104) |
/// | [EncryptedPayload] | Modelo de payload — JSON/Base64 |
/// | [CryptException] | Exceção de autenticação falha |
library all_validations_br.crypt;

export 'src/crypt/crypt_util.dart';
