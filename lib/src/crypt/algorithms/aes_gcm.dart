import 'dart:typed_data';

import '../models/crypt_exception.dart';
import '../models/encrypted_payload.dart';
import 'aes_core.dart';

// ---------------------------------------------------------------------------
// AES-GCM — NIST SP 800-38D
// ---------------------------------------------------------------------------
//
// Cifra autenticada (AEAD) combinando AES-CTR + GHASH.
// Suporta chaves de 128 bits (16 bytes) e 256 bits (32 bytes).
// Nonce padrão: 96 bits (12 bytes).  Tag: 128 bits (16 bytes).

/// Implementação do cipher autenticado AES-GCM (AEAD) — NIST SP 800-38D.
///
/// Equivalente moderno ao ChaCha20-Poly1305 para casos que exigem AES.
///
/// ```dart
/// final key = CryptUtil.generateKey(); // 32 bytes → AES-256
/// final nonce = Uint8List(12);
/// Random.secure().nextBytes(nonce);
///
/// final gcm = AesGcm(key: key, nonce: nonce, aad: Uint8List(0));
/// final payload = gcm.encrypt(utf8.encode('texto secreto'));
/// final texto = utf8.decode(gcm.decrypt(payload));
/// ```
class AesGcm {
  static const int nonceLength = 12;
  static const int tagLength = 16;

  final Uint8List key;
  final Uint8List nonce;
  final Uint8List aad;

  const AesGcm({
    required this.key,
    required this.nonce,
    required this.aad,
  });

  /// Cifra [plaintext] e retorna um [EncryptedPayload] com ciphertext e tag GCM.
  EncryptedPayload encrypt(List<int> plaintext) {
    _validate();
    final ek = aesExpandKey(key);
    final h = aesEncryptBlock(Uint8List(16), ek); // H = AES_K(0^128)
    final j0 = _makeJ0();
    final ct = _gctr(ek, _inc32(j0), plaintext);
    final tag = _computeTag(ek, h, j0, ct);

    return EncryptedPayload(
      algorithm: 'aes-gcm',
      ciphertext: Uint8List.fromList(ct),
      key: key,
      tag: tag,
      nonce: nonce,
      aad: aad,
    );
  }

  /// Decifra [payload] e retorna o plaintext original.
  ///
  /// Lança [CryptException] se a tag de autenticação não for válida.
  List<int> decrypt(EncryptedPayload payload) {
    _validate();
    final ek = aesExpandKey(key);
    final h = aesEncryptBlock(Uint8List(16), ek);
    final j0 = _makeJ0();

    final expectedTag = _computeTag(ek, h, j0, payload.ciphertext);
    if (!_ctEqual(payload.tag, expectedTag)) {
      throw const CryptException(
          'Tag GCM inválida. Dados corrompidos ou chave incorreta.');
    }
    return _gctr(ek, _inc32(j0), payload.ciphertext);
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  void _validate() {
    if (key.length != 16 && key.length != 32) {
      throw ArgumentError(
          'AES-GCM: chave deve ter 16 (AES-128) ou 32 (AES-256) bytes.');
    }
    if (nonce.length != nonceLength) {
      throw ArgumentError('AES-GCM: nonce deve ter $nonceLength bytes.');
    }
  }

  /// J0 = IV[0..11] || 00000001 (para nonce de 96 bits)
  Uint8List _makeJ0() {
    final j0 = Uint8List(16);
    j0.setRange(0, 12, nonce);
    j0[15] = 0x01;
    return j0;
  }

  /// Inc32: incrementa os últimos 4 bytes (big-endian) sem modificar o original.
  Uint8List _inc32(Uint8List b) {
    final r = Uint8List.fromList(b);
    for (int i = 15; i >= 12; i--) {
      if (++r[i] != 0) break;
    }
    return r;
  }

  // ---------------------------------------------------------------------------
  // GCTR — AES-CTR com Inc32
  // ---------------------------------------------------------------------------

  /// Cifra ou decifra [data] em modo CTR a partir do contador inicial [icb].
  List<int> _gctr(Uint8List ek, Uint8List icb, List<int> data) {
    if (data.isEmpty) return [];
    final out = Uint8List(data.length);
    final ctr = Uint8List.fromList(icb);
    int offset = 0;

    while (offset < data.length) {
      final enc = aesEncryptBlock(ctr, ek);
      final len = (data.length - offset).clamp(0, 16);
      for (int i = 0; i < len; i++) {
        out[offset + i] = data[offset + i] ^ enc[i];
      }
      offset += len;
      // Incrementa o contador (não importa se é o último bloco)
      for (int i = 15; i >= 12; i--) {
        if (++ctr[i] != 0) break;
      }
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Tag GCM: T = E_K(J0) XOR GHASH_H(A || 0^v || C || 0^u || lenA || lenC)
  // ---------------------------------------------------------------------------

  Uint8List _computeTag(Uint8List ek, Uint8List h, Uint8List j0, List<int> c) {
    final s = _ghash(h, aad, c);
    final eJ0 = aesEncryptBlock(j0, ek);
    final tag = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      tag[i] = s[i] ^ eJ0[i];
    }
    return tag;
  }

  // ---------------------------------------------------------------------------
  // GHASH
  // ---------------------------------------------------------------------------

  /// GHASH_H(A || pad(A) || C || pad(C) || [len(A)]_64 || [len(C)]_64)
  Uint8List _ghash(Uint8List h, Uint8List a, List<int> c) {
    final hHi = _b2i64(h, 0);
    final hLo = _b2i64(h, 8);
    int xHi = 0, xLo = 0;

    // Processa AAD em blocos de 16 bytes (zero-padded)
    var r = _ghashBlocks(a, 0, a.length, xHi, xLo, hHi, hLo);
    xHi = r[0]; xLo = r[1];

    // Processa ciphertext em blocos de 16 bytes (zero-padded)
    final ct = c is Uint8List ? c : Uint8List.fromList(c);
    r = _ghashBlocks(ct, 0, ct.length, xHi, xLo, hHi, hLo);
    xHi = r[0]; xLo = r[1];

    // Bloco de comprimentos: [len(A)*8]_64 || [len(C)*8]_64 (big-endian)
    final lb = Uint8List(16);
    ByteData.sublistView(lb)
      ..setUint64(0, a.length * 8, Endian.big)
      ..setUint64(8, c.length * 8, Endian.big);

    xHi ^= _b2i64(lb, 0);
    xLo ^= _b2i64(lb, 8);
    r = _gcmMul(xHi, xLo, hHi, hLo);
    xHi = r[0]; xLo = r[1];

    final result = Uint8List(16);
    _i64b(xHi, result, 0);
    _i64b(xLo, result, 8);
    return result;
  }

  /// Itera sobre [data] em blocos de 16 bytes, acumulando o estado GHASH.
  List<int> _ghashBlocks(
    List<int> data, int start, int end,
    int xHi, int xLo,
    int hHi, int hLo,
  ) {
    final block = Uint8List(16);
    int offset = start;

    while (offset < end) {
      final len = (end - offset).clamp(0, 16);
      block.fillRange(0, 16, 0);
      for (int i = 0; i < len; i++) {
        block[i] = data[offset + i];
      }

      xHi ^= _b2i64(block, 0);
      xLo ^= _b2i64(block, 8);

      final r = _gcmMul(xHi, xLo, hHi, hLo);
      xHi = r[0]; xLo = r[1];
      offset += 16;
    }
    return [xHi, xLo];
  }

  // ---------------------------------------------------------------------------
  // GF(2^128) — multiplicação GCM (NIST SP 800-38D §6.3)
  // ---------------------------------------------------------------------------
  //
  // Representação: [hi, lo] como int64 big-endian.
  // Bit mais significativo de `hi` = coeficiente de x^127.
  // Polinômio redutor: x^128 + x^7 + x^2 + x + 1
  // R = 1110 0001 || 0^120 → rHi = 0xe100_0000_0000_0000

  List<int> _gcmMul(int xHi, int xLo, int yHi, int yLo) {
    int zHi = 0, zLo = 0;
    int vHi = xHi, vLo = xLo;

    for (int i = 0; i < 2; i++) {
      int word = (i == 0) ? yHi : yLo;
      for (int bit = 63; bit >= 0; bit--) {
        if ((word >>> bit) & 1 == 1) {
          zHi ^= vHi;
          zLo ^= vLo;
        }
        // Shift V à direita por 1 bit
        final lsb = vLo & 1;
        vLo = (vLo >>> 1) | (vHi << 63);
        vHi = vHi >>> 1;
        // Se bit deslocado era 1: XOR com R = 0xE100000000000000 || 0
        if (lsb == 1) {
          vHi ^= 0xe100000000000000; // -0x1f00000000000000 em signed int64
        }
      }
    }
    return [zHi, zLo];
  }

  // ---------------------------------------------------------------------------
  // Utilitários bytes ↔ int64 (big-endian)
  // ---------------------------------------------------------------------------

  int _b2i64(List<int> b, int o) =>
      ((b[o] & 0xff) << 56) |
      ((b[o+1] & 0xff) << 48) |
      ((b[o+2] & 0xff) << 40) |
      ((b[o+3] & 0xff) << 32) |
      ((b[o+4] & 0xff) << 24) |
      ((b[o+5] & 0xff) << 16) |
      ((b[o+6] & 0xff) << 8) |
       (b[o+7] & 0xff);

  void _i64b(int v, Uint8List b, int o) {
    b[o]   = (v >> 56) & 0xff;
    b[o+1] = (v >> 48) & 0xff;
    b[o+2] = (v >> 40) & 0xff;
    b[o+3] = (v >> 32) & 0xff;
    b[o+4] = (v >> 24) & 0xff;
    b[o+5] = (v >> 16) & 0xff;
    b[o+6] = (v >> 8)  & 0xff;
    b[o+7] =  v        & 0xff;
  }

  bool _ctEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
