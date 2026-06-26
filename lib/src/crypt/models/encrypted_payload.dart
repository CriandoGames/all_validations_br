import 'dart:convert';
import 'dart:typed_data';

/// Resultado de uma operação de criptografia ChaCha20-Poly1305.
///
/// Contém todos os dados necessários para decriptação:
/// - [ciphertext] : dados cifrados
/// - [key]        : chave de 32 bytes usada na cifragem
/// - [tag]        : tag de autenticação Poly1305 de 16 bytes
/// - [nonce]      : nonce de 12 bytes usado na cifragem
/// - [aad]        : dados adicionais autenticados (pode ser vazio)
class EncryptedPayload {
  final Uint8List ciphertext;
  final Uint8List key;
  final Uint8List tag;
  final Uint8List nonce;
  final Uint8List aad;

  const EncryptedPayload({
    required this.ciphertext,
    required this.key,
    required this.tag,
    required this.nonce,
    required this.aad,
  });

  /// Serializa o payload para um Map JSON.
  ///
  /// Todos os campos de bytes são codificados em base64.
  Map<String, dynamic> toJson() => {
        'ciphertext': base64.encode(ciphertext),
        'key': base64.encode(key),
        'tag': base64.encode(tag),
        'nonce': base64.encode(nonce),
        'aad': base64.encode(aad),
      };

  /// Deserializa um [EncryptedPayload] a partir de um Map JSON.
  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedPayload(
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
  String toString() =>
      'EncryptedPayload(ciphertext: ${ciphertext.length} bytes, '
      'key: ${key.length} bytes, tag: ${tag.length} bytes, '
      'nonce: ${nonce.length} bytes, aad: ${aad.length} bytes)';
}
