import 'dart:typed_data';

import '../models/crypt_exception.dart';
import '../models/encrypted_payload.dart';
import 'aes_core.dart';

// ---------------------------------------------------------------------------
// AES-CBC — NIST SP 800-38A (Cipher Block Chaining)
// ---------------------------------------------------------------------------
//
// Modo de encadeamento de blocos com padding PKCS#7.
// Não é autenticado — use AES-GCM ou ChaCha20-Poly1305 quando precisar
// de integridade garantida.
//
// Suporta AES-128 (16 bytes) e AES-256 (32 bytes).
// IV: exatamente 16 bytes (gerado aleatoriamente fora da classe).

/// Implementação de AES-CBC (NIST SP 800-38A) com padding PKCS#7.
///
/// ⚠️  CBC **não é autenticado** — considere AES-GCM para AEAD.
///
/// ```dart
/// final cbc = AesCbc(key: key32, iv: iv16);
/// final payload = cbc.encrypt(utf8.encode('dados'));
/// final texto  = utf8.decode(cbc.decrypt(payload));
/// ```
class AesCbc {
  static const int ivLength = 16;

  final Uint8List key;
  final Uint8List iv;

  const AesCbc({required this.key, required this.iv});

  /// Cifra [plaintext] com PKCS#7 e retorna [EncryptedPayload].
  ///
  /// O campo `tag` do payload é vazio — CBC não produz MAC.
  EncryptedPayload encrypt(List<int> plaintext) {
    _validate();
    final ek = aesExpandKey(key);
    final padded = _pkcs7Pad(plaintext);
    final ct = Uint8List(padded.length);
    Uint8List prev = iv;

    for (int i = 0; i < padded.length; i += 16) {
      // XOR bloco de plaintext com bloco anterior (ou IV)
      final block = Uint8List(16);
      for (int j = 0; j < 16; j++) {
        block[j] = padded[i + j] ^ prev[j];
      }
      final enc = aesEncryptBlock(block, ek);
      ct.setRange(i, i + 16, enc);
      prev = enc;
    }

    return EncryptedPayload(
      algorithm: 'aes-cbc',
      ciphertext: ct,
      key: key,
      tag: Uint8List(0), // CBC não produz tag de autenticação
      nonce: iv,
      aad: Uint8List(0),
    );
  }

  /// Decifra [payload] e retorna o plaintext sem padding.
  ///
  /// Lança [CryptException] se o padding PKCS#7 for inválido.
  List<int> decrypt(EncryptedPayload payload) {
    _validate();
    final ek = aesExpandKey(key);
    final ct = payload.ciphertext;

    if (ct.isEmpty || ct.length % 16 != 0) {
      throw const CryptException(
          'AES-CBC: comprimento do ciphertext inválido (deve ser múltiplo de 16).');
    }

    final pt = Uint8List(ct.length);
    Uint8List prev = iv;

    for (int i = 0; i < ct.length; i += 16) {
      final block = ct.sublist(i, i + 16);
      final dec = aesDecryptBlock(block, ek);
      for (int j = 0; j < 16; j++) {
        pt[i + j] = dec[j] ^ prev[j];
      }
      prev = block;
    }

    return _pkcs7Unpad(pt);
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  void _validate() {
    if (key.length != 16 && key.length != 32) {
      throw ArgumentError(
          'AES-CBC: chave deve ter 16 (AES-128) ou 32 (AES-256) bytes.');
    }
    if (iv.length != ivLength) {
      throw ArgumentError('AES-CBC: IV deve ter $ivLength bytes.');
    }
  }

  /// Adiciona padding PKCS#7: padLen bytes de valor padLen.
  ///
  /// Sempre adiciona pelo menos 1 byte (e um bloco inteiro se alinhado).
  Uint8List _pkcs7Pad(List<int> data) {
    final padLen = 16 - (data.length % 16);
    final out = Uint8List(data.length + padLen);
    for (int i = 0; i < data.length; i++) {
      out[i] = data[i];
    }
    out.fillRange(data.length, out.length, padLen);
    return out;
  }

  /// Remove e verifica padding PKCS#7.
  ///
  /// Lança [CryptException] se o padding for inválido.
  List<int> _pkcs7Unpad(Uint8List data) {
    if (data.isEmpty) {
      throw const CryptException('AES-CBC: dados vazios após decifração.');
    }
    final padLen = data.last;
    if (padLen == 0 || padLen > 16 || padLen > data.length) {
      throw const CryptException('AES-CBC: padding PKCS#7 inválido.');
    }
    // Verificação em tempo constante de todos os bytes de padding
    int diff = 0;
    for (int i = data.length - padLen; i < data.length; i++) {
      diff |= data[i] ^ padLen;
    }
    if (diff != 0) {
      throw const CryptException('AES-CBC: padding PKCS#7 inválido.');
    }
    return data.sublist(0, data.length - padLen);
  }
}
