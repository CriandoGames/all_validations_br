/// Identificadores de algoritmos suportados pelo módulo crypt.
///
/// Usado no campo [EncryptedPayload.algorithm] para identificar o algoritmo
/// utilizado na cifragem e despachar o decifrador correto em [CryptUtil.decryptAny].
///
/// ```dart
/// final payload = CryptUtil.encryptAesGcm(dados);
/// print(payload.algorithm);          // CryptAlgorithm.aesGcm
/// print(payload.algorithm.value);    // 'aes-gcm'
/// ```
enum CryptAlgorithm {
  /// ChaCha20-Poly1305 — AEAD, padrão da lib (RFC 8439).
  chacha20Poly1305('chacha20-poly1305'),

  /// AES-GCM — AEAD (NIST SP 800-38D). Suporta AES-128 e AES-256.
  aesGcm('aes-gcm'),

  /// AES-CBC + PKCS#7 — não autenticado (NIST SP 800-38A).
  aesCbc('aes-cbc'),

  /// AES-CTR — não autenticado (NIST SP 800-38A).
  aesCtr('aes-ctr');

  // ---------------------------------------------------------------------------

  /// Identificador serializado — usado em JSON e no campo `algorithm` do payload.
  final String value;

  const CryptAlgorithm(this.value);

  /// Converte uma string (vinda de JSON) para o enum correspondente.
  ///
  /// Lança [ArgumentError] para strings não reconhecidas.
  ///
  /// ```dart
  /// CryptAlgorithm.fromString('aes-gcm'); // CryptAlgorithm.aesGcm
  /// ```
  static CryptAlgorithm fromString(String s) => values.firstWhere(
        (e) => e.value == s,
        orElse: () =>
            throw ArgumentError('CryptAlgorithm desconhecido: "$s".'),
      );
}
