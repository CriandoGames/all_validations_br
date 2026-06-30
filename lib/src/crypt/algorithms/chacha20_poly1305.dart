import 'dart:typed_data';

import '../models/crypt_algorithm.dart';
import '../models/crypt_exception.dart';
import '../models/encrypted_payload.dart';
import 'chacha20.dart';

/// Implementação do cipher autenticado ChaCha20-Poly1305 (AEAD) — RFC 8439.
///
/// Combina a cifra de stream ChaCha20 com o MAC Poly1305 para garantir
/// confidencialidade e integridade dos dados em uma única operação.
///
/// Tamanhos esperados:
/// - Chave  : 32 bytes
/// - Nonce  : 12 bytes
/// - Tag    : 16 bytes (gerada automaticamente)
class ChaCha20Poly1305 {
  static const int keyLength = 32;
  static const int nonceLength = 12;
  static const int tagLength = 16;

  final Uint8List key;
  final Uint8List nonce;
  final Uint8List aad;

  const ChaCha20Poly1305({
    required this.key,
    required this.nonce,
    required this.aad,
  });

  /// Cifra [plaintext] e retorna um [EncryptedPayload] com ciphertext e tag.
  ///
  /// Lança [ArgumentError] se [key] ou [nonce] tiverem tamanho inválido.
  EncryptedPayload encrypt(List<int> plaintext) {
    _validateKeyNonce();

    final ciphertext = chacha20Encrypt(key, 1, nonce, plaintext);
    final polyKey = poly1305KeyGen(key, nonce);
    final tag = calculateTag(ciphertext, aad, polyKey);

    return EncryptedPayload(
      algorithm: CryptAlgorithm.chacha20Poly1305,
      ciphertext: Uint8List.fromList(ciphertext),
      key: key,
      tag: tag,
      nonce: nonce,
      aad: aad,
    );
  }

  /// Decifra [payload] e retorna o plaintext original.
  ///
  /// Lança [CryptException] se a tag de autenticação não for válida.
  /// Lança [ArgumentError] se [key] ou [nonce] tiverem tamanho inválido.
  List<int> decrypt(EncryptedPayload payload) {
    _validateKeyNonce();

    if (payload.tag.length != tagLength) {
      throw ArgumentError('Tag inválida: deve ter $tagLength bytes.');
    }

    final polyKey = poly1305KeyGen(key, nonce);
    final expectedTag = calculateTag(payload.ciphertext, aad, polyKey);

    if (!constantTimeCompare(payload.tag, expectedTag)) {
      throw const CryptException('Tag de autenticação inválida. '
          'Os dados podem ter sido corrompidos ou a chave está incorreta.');
    }

    return chacha20Encrypt(key, 1, nonce, payload.ciphertext);
  }

  void _validateKeyNonce() {
    if (key.length != keyLength) {
      throw ArgumentError('Chave inválida: deve ter $keyLength bytes.');
    }
    if (nonce.length != nonceLength) {
      throw ArgumentError('Nonce inválido: deve ter $nonceLength bytes.');
    }
  }
}
