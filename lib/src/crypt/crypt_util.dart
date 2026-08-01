import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'algorithms/aes_cbc.dart';
import 'algorithms/aes_ctr.dart';
import 'algorithms/aes_gcm.dart';
import 'algorithms/chacha20_poly1305.dart';
import 'models/crypt_algorithm.dart';
import 'models/crypt_exception.dart';
import 'models/encrypted_payload.dart';

export 'algorithms/aes_cbc.dart';
export 'algorithms/aes_ctr.dart';
export 'algorithms/aes_gcm.dart';
export 'algorithms/hmac_sha256.dart';
export 'algorithms/sha256.dart';
export 'models/crypt_algorithm.dart';
export 'models/crypt_exception.dart';
export 'models/encrypted_payload.dart';

/// Utilitário de criptografia com suporte a múltiplos algoritmos.
///
/// Implementação Dart pura, **zero dependências externas**.
/// Todos os algoritmos operam sobre [EncryptedPayload], que serializa
/// chave, nonce, ciphertext, tag e algoritmo em JSON/Base64.
///
/// ## Algoritmos disponíveis
///
/// | Algoritmo | Segurança | Método |
/// |-----------|-----------|--------|
/// | ChaCha20-Poly1305 (padrão) | AEAD ✓ | [encryptBytes] / [decryptBytes] |
/// | AES-256-GCM | AEAD ✓ | [encryptAesGcm] / [decryptAesGcm] |
/// | AES-CBC + PKCS#7 | Não autenticado ⚠️ | [encryptAesCbc] / [decryptAesCbc] |
/// | AES-CTR | Não autenticado ⚠️ | [encryptAesCtr] / [decryptAesCtr] |
///
/// Use [decryptAny] para decifrar qualquer [EncryptedPayload]
/// independente do algoritmo utilizado na cifragem.
///
/// ## Uso rápido — ChaCha20-Poly1305 (recomendado)
///
/// ```dart
/// final key     = CryptUtil.generateKey();         // 32 bytes
/// final payload = CryptUtil.encryptText('segredo', key: key);
/// final texto   = CryptUtil.decryptText(payload);  // 'segredo'
/// ```
///
/// ## AES-256-GCM (compatibilidade com sistemas AES)
///
/// ```dart
/// final key     = CryptUtil.generateKey();          // 32 bytes → AES-256
/// final nonce   = CryptUtil.generateNonce();        // 12 bytes
/// final payload = CryptUtil.encryptAesGcm(dados, key: key, nonce: nonce);
/// final dados   = CryptUtil.decryptAesGcm(payload);
/// ```
///
/// ## Dispatch automático
///
/// ```dart
/// // Decifra qualquer payload, independente do algoritmo
/// final plain = CryptUtil.decryptAny(payload);
/// ```
///
/// ## Serialização
///
/// ```dart
/// final encoded  = payload.toBase64();
/// final restored = EncryptedPayload.fromBase64(encoded);
/// final texto    = CryptUtil.decryptText(restored);
/// ```
///
/// ## Segurança
///
/// - **Nunca reutilize** o mesmo par (key, nonce/iv) para mensagens diferentes.
/// - **Armazene a chave** em local seguro (`flutter_secure_storage`, keychain, etc.).
/// - **Prefira AEAD** (ChaCha20-Poly1305 ou AES-GCM) — detectam adulteração.
/// - **CBC e CTR não são autenticados** — combine com HMAC-SHA256 se necessário.
class CryptUtil {
  CryptUtil._();

  // ===========================================================================
  // ChaCha20-Poly1305 — padrão, AEAD (RFC 8439)
  // ===========================================================================

  /// Criptografa [text] com ChaCha20-Poly1305 e retorna um [EncryptedPayload].
  ///
  /// - [key]   : 32 bytes. Se omitido, gera uma chave aleatória segura.
  /// - [nonce] : 12 bytes. Se omitido, gera um nonce aleatório seguro.
  /// - [aad]   : dados autenticados mas não cifrados (opcional).
  static EncryptedPayload encryptText(
    String text, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) =>
      encryptBytes(utf8.encode(text), key: key, nonce: nonce, aad: aad);

  /// Decriptografa [payload] (ChaCha20-Poly1305) e retorna a string original.
  ///
  /// Lança [CryptException] se a tag de autenticação for inválida.
  static String decryptText(EncryptedPayload payload) =>
      utf8.decode(decryptBytes(payload));

  /// Criptografa [bytes] com ChaCha20-Poly1305 e retorna um [EncryptedPayload].
  ///
  /// - [key]   : 32 bytes. Se omitido, gera uma chave aleatória segura.
  /// - [nonce] : 12 bytes. Se omitido, gera um nonce aleatório seguro.
  /// - [aad]   : dados autenticados mas não cifrados (opcional).
  static EncryptedPayload encryptBytes(
    List<int> bytes, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) {
    final cipher = ChaCha20Poly1305(
      key: key ?? generateKey(),
      nonce: nonce ?? generateNonce(),
      aad: aad != null ? Uint8List.fromList(aad) : Uint8List(0),
    );
    return cipher.encrypt(bytes);
  }

  /// Decriptografa [payload] (ChaCha20-Poly1305) e retorna os bytes originais.
  ///
  /// Lança [CryptException] se a tag de autenticação for inválida.
  static List<int> decryptBytes(EncryptedPayload payload) =>
      ChaCha20Poly1305(
        key: payload.key,
        nonce: payload.nonce,
        aad: payload.aad,
      ).decrypt(payload);

  /// Criptografa [text] e retorna o payload como string base64.
  ///
  /// ```dart
  /// final b64 = CryptUtil.encryptToBase64('segredo', key: key);
  /// final txt = CryptUtil.decryptFromBase64(b64);
  /// ```
  static String encryptToBase64(
    String text, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) =>
      encryptText(text, key: key, nonce: nonce, aad: aad).toBase64();

  /// Decriptografa um payload base64 gerado por [encryptToBase64].
  ///
  /// Lança [CryptException] se os dados forem adulterados.
  /// Lança [FormatException] se [encoded] não for base64 válido.
  static String decryptFromBase64(String encoded) =>
      decryptText(EncryptedPayload.fromBase64(encoded));

  // ===========================================================================
  // AES-GCM — AEAD (NIST SP 800-38D)
  // ===========================================================================

  /// Criptografa [bytes] com AES-GCM e retorna um [EncryptedPayload].
  ///
  /// - [key]   : 16 bytes (AES-128) ou 32 bytes (AES-256). Padrão: 32 bytes.
  /// - [nonce] : 12 bytes. Se omitido, gera um nonce aleatório seguro.
  /// - [aad]   : dados autenticados mas não cifrados (opcional).
  ///
  /// ```dart
  /// final payload = CryptUtil.encryptAesGcm(dados, key: key);
  /// final plain   = CryptUtil.decryptAesGcm(payload);
  /// ```
  static EncryptedPayload encryptAesGcm(
    List<int> bytes, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) =>
      AesGcm(
        key: key ?? generateKey(),
        nonce: nonce ?? generateNonce(),
        aad: aad != null ? Uint8List.fromList(aad) : Uint8List(0),
      ).encrypt(bytes);

  /// Decriptografa [payload] (AES-GCM) e retorna os bytes originais.
  ///
  /// Lança [CryptException] se a tag GCM for inválida.
  static List<int> decryptAesGcm(EncryptedPayload payload) =>
      AesGcm(
        key: payload.key,
        nonce: payload.nonce,
        aad: payload.aad,
      ).decrypt(payload);

  // ===========================================================================
  // AES-CBC — com PKCS#7 (NIST SP 800-38A) ⚠️ não autenticado
  // ===========================================================================

  /// Criptografa [bytes] com AES-CBC + PKCS#7 e retorna um [EncryptedPayload].
  ///
  /// ⚠️  **Não autenticado** — use AES-GCM ou ChaCha20-Poly1305 quando precisar
  /// de integridade garantida.
  ///
  /// - [key] : 16 bytes (AES-128) ou 32 bytes (AES-256). Padrão: 32 bytes.
  /// - [iv]  : 16 bytes. Se omitido, gera um IV aleatório seguro.
  static EncryptedPayload encryptAesCbc(
    List<int> bytes, {
    Uint8List? key,
    Uint8List? iv,
  }) =>
      AesCbc(
        key: key ?? generateKey(),
        iv: iv ?? generateIv(),
      ).encrypt(bytes);

  /// Decriptografa [payload] (AES-CBC) e retorna os bytes sem padding.
  ///
  /// Lança [CryptException] se o padding PKCS#7 for inválido.
  static List<int> decryptAesCbc(EncryptedPayload payload) =>
      AesCbc(
        key: payload.key,
        iv: payload.nonce, // nonce armazena o IV no EncryptedPayload
      ).decrypt(payload);

  // ===========================================================================
  // AES-CTR — modo contador (NIST SP 800-38A) ⚠️ não autenticado
  // ===========================================================================

  /// Criptografa [bytes] com AES-CTR e retorna um [EncryptedPayload].
  ///
  /// ⚠️  **Não autenticado** — use AES-GCM ou ChaCha20-Poly1305 quando precisar
  /// de integridade garantida.
  ///
  /// - [key]                : 16 bytes (AES-128) ou 32 bytes (AES-256). Padrão: 32 bytes.
  /// - [initialCounterBlock]: 16 bytes. Se omitido, gera um bloco aleatório seguro.
  static EncryptedPayload encryptAesCtr(
    List<int> bytes, {
    Uint8List? key,
    Uint8List? initialCounterBlock,
  }) =>
      AesCtr(
        key: key ?? generateKey(),
        initialCounterBlock: initialCounterBlock ?? generateIv(),
      ).encrypt(bytes);

  /// Decriptografa [payload] (AES-CTR) e retorna os bytes originais.
  static List<int> decryptAesCtr(EncryptedPayload payload) =>
      AesCtr(
        key: payload.key,
        initialCounterBlock: payload.nonce,
      ).decrypt(payload);

  // ===========================================================================
  // Dispatch automático — decifra qualquer payload pelo campo `algorithm`
  // ===========================================================================

  /// Decifra [payload] despachando para o algoritmo correto automaticamente.
  ///
  /// Lê o campo [EncryptedPayload.algorithm] e chama o método correspondente.
  ///
  /// Algoritmos suportados: `chacha20-poly1305`, `aes-gcm`, `aes-cbc`, `aes-ctr`.
  ///
  /// Lança [CryptException] para algoritmos desconhecidos.
  ///
  /// ```dart
  /// final plain = CryptUtil.decryptAny(payload); // funciona com qualquer algoritmo
  /// ```
  static List<int> decryptAny(EncryptedPayload payload) {
    switch (payload.algorithm) {
      case CryptAlgorithm.chacha20Poly1305:
        return decryptBytes(payload);
      case CryptAlgorithm.aesGcm:
        return decryptAesGcm(payload);
      case CryptAlgorithm.aesCbc:
        return decryptAesCbc(payload);
      case CryptAlgorithm.aesCtr:
        return decryptAesCtr(payload);
    }
  }

  // ===========================================================================
  // Geração de material criptográfico
  // ===========================================================================

  /// Gera uma chave criptograficamente segura de **32 bytes** (AES-256 / ChaCha20).
  ///
  /// Para AES-128, use [generateKey128].
  static Uint8List generateKey() => _randomBytes(32);

  /// Gera uma chave criptograficamente segura de **16 bytes** (AES-128).
  static Uint8List generateKey128() => _randomBytes(16);

  /// Gera um nonce criptograficamente seguro de **12 bytes** (ChaCha20 / AES-GCM).
  ///
  /// **Nunca reutilize** o mesmo nonce com a mesma chave.
  static Uint8List generateNonce() => _randomBytes(12);

  /// Gera um IV criptograficamente seguro de **16 bytes** (AES-CBC / AES-CTR).
  ///
  /// **Nunca reutilize** o mesmo IV com a mesma chave.
  static Uint8List generateIv() => _randomBytes(16);

  // ===========================================================================
  // Privado
  // ===========================================================================

  static Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
  }
}
