import 'dart:convert';
import 'dart:typed_data';

/// Resultado de uma operação de criptografia simétrica.
///
/// Contém todos os dados necessários para decriptação:
/// - [ciphertext] : dados cifrados
/// - [key]        : chave usada na cifragem
/// - [tag]        : tag de autenticação (MAC) — pode ser vazia em modos sem autenticação
/// - [nonce]      : nonce / IV usado na cifragem
/// - [aad]        : dados adicionais autenticados (pode ser vazio)
/// - [algorithm]  : identificador do algoritmo usado (ex.: 'chacha20-poly1305', 'aes-gcm')
class EncryptedPayload {
  final Uint8List ciphertext;
  final Uint8List key;
  final Uint8List tag;
  final Uint8List nonce;
  final Uint8List aad;

  /// Identificador do algoritmo de criptografia utilizado.
  ///
  /// Valores conhecidos:
  /// - `'chacha20-poly1305'` — ChaCha20-Poly1305 (RFC 8439)
  /// - `'aes-gcm'`           — AES-GCM
  /// - `'aes-cbc'`           — AES-CBC com PKCS7
  /// - `'aes-ctr'`           — AES-CTR
  /// - `'salsa20'`           — Salsa20
  ///
  /// Payloads antigos sem este campo assumem `'chacha20-poly1305'`.
  final String algorithm;

  const EncryptedPayload({
    required this.ciphertext,
    required this.key,
    required this.tag,
    required this.nonce,
    required this.aad,
    this.algorithm = 'chacha20-poly1305',
  });

  /// Serializa o payload para um Map JSON.
  ///
  /// Todos os campos de bytes são codificados em base64.
  Map<String, dynamic> toJson() => {
        'algorithm': algorithm,
        'ciphertext': base64.encode(ciphertext),
        'key': base64.encode(key),
        'tag': base64.encode(tag),
        'nonce': base64.encode(nonce),
        'aad': base64.encode(aad),
      };

  /// Deserializa um [EncryptedPayload] a partir de um Map JSON.
  ///
  /// O campo `algorithm` é opcional para compatibilidade com payloads antigos
  /// — se ausente, assume `'chacha20-poly1305'`.
  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedPayload(
      algorithm: (json['algorithm'] as String?) ?? 'chacha20-poly1305',
      ciphertext: base64.decode(json['ciphertext'] as String),
      key: base64.decode(json['key'] as String),
      tag: base64.decode(json['tag'] as String),
      nonce: base64.decode(json['nonce'] as String),
      aad: base64.decode(json['aad'] as String),
    );
  }

  /// Serializa o payload inteiro para uma string JSON base64.
  ///
  /// Útil para armazenar ou transmitir o payload como uma string única.
  String toBase64() => base64.encode(utf8.encode(jsonEncode(toJson())));

  /// Deserializa um [EncryptedPayload] a partir de uma string JSON base64.
  factory EncryptedPayload.fromBase64(String encoded) {
    final json = jsonDecode(utf8.decode(base64.decode(encoded)));
    return EncryptedPayload.fromJson(json as Map<String, dynamic>);
  }

  @override
  String toString() => 'EncryptedPayload(algorithm: $algorithm, '
      'ciphertext: ${ciphertext.length} bytes, '
      'key: ${key.length} bytes, tag: ${tag.length} bytes, '
      'nonce: ${nonce.length} bytes, aad: ${aad.length} bytes)';
}
