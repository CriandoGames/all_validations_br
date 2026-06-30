import 'dart:typed_data';

import '../models/crypt_algorithm.dart';
import '../models/crypt_exception.dart';
import '../models/encrypted_payload.dart';
import 'aes_core.dart';

// ---------------------------------------------------------------------------
// AES-CTR — NIST SP 800-38A (Counter Mode)
// ---------------------------------------------------------------------------
//
// Modo de fluxo: AES(contador) XOR plaintext.
// Cifrar e decifrar são a mesma operação (simétrico).
// O contador é incrementado via Inc128 (big-endian, bloco completo de 16 bytes).
//
// Não é autenticado — use AES-GCM ou ChaCha20-Poly1305 quando precisar
// de integridade garantida.
//
// Suporta AES-128 (16 bytes) e AES-256 (32 bytes).
// initialCounterBlock: exatamente 16 bytes.

/// Implementação de AES-CTR (NIST SP 800-38A, modo de contador).
///
/// ⚠️  CTR **não é autenticado** — considere AES-GCM para AEAD.
///
/// O [initialCounterBlock] é o bloco de contador inicial (16 bytes).
/// Compatível com os vetores NIST que usam Inc128 (incrementa o bloco
/// inteiro como inteiro big-endian de 128 bits).
///
/// ```dart
/// final ctr = AesCtr(key: key32, initialCounterBlock: icb);
/// final payload = ctr.encrypt(dados);
/// final original = ctr.decrypt(payload);
/// ```
class AesCtr {
  static const int counterBlockLength = 16;

  final Uint8List key;

  /// Bloco de contador inicial — 16 bytes interpretados como uint128 big-endian.
  final Uint8List initialCounterBlock;

  const AesCtr({
    required this.key,
    required this.initialCounterBlock,
  });

  /// Cifra [plaintext] e retorna [EncryptedPayload].
  ///
  /// O campo `tag` do payload é vazio — CTR não produz MAC.
  EncryptedPayload encrypt(List<int> plaintext) {
    _validate();
    return EncryptedPayload(
      algorithm: CryptAlgorithm.aesCtr,
      ciphertext: Uint8List.fromList(_ctr(plaintext)),
      key: key,
      nonce: initialCounterBlock,
      // tag e aad omitidos → Uint8List(0) por padrão
    );
  }

  /// Decifra [payload] e retorna o plaintext.
  ///
  /// Operação idêntica a [encrypt] (CTR é simétrico).
  /// Lança [CryptException] se o payload usar um algoritmo diferente.
  List<int> decrypt(EncryptedPayload payload) {
    _validate();
    if (payload.algorithm != CryptAlgorithm.aesCtr) {
      throw CryptException(
          'AES-CTR: algoritmo incompatível no payload (${payload.algorithm}).');
    }
    return _ctr(payload.ciphertext);
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  void _validate() {
    if (key.length != 16 && key.length != 32) {
      throw ArgumentError(
          'AES-CTR: chave deve ter 16 (AES-128) ou 32 (AES-256) bytes.');
    }
    if (initialCounterBlock.length != counterBlockLength) {
      throw ArgumentError(
          'AES-CTR: initialCounterBlock deve ter $counterBlockLength bytes.');
    }
  }

  /// Aplica AES-CTR: XOR de cada byte com o keystream gerado por AES(contador).
  ///
  /// Inc128: incrementa o bloco de 16 bytes como inteiro big-endian de 128 bits.
  List<int> _ctr(List<int> data) {
    if (data.isEmpty) return [];
    final ek = aesExpandKey(key);
    final out = Uint8List(data.length);
    final ctr = Uint8List.fromList(initialCounterBlock);
    int offset = 0;

    while (offset < data.length) {
      final keyBlock = aesEncryptBlock(ctr, ek);
      final len = (data.length - offset).clamp(0, 16);
      for (int i = 0; i < len; i++) {
        out[offset + i] = data[offset + i] ^ keyBlock[i];
      }
      offset += len;
      // Inc128: incrementa o bloco inteiro como uint128 big-endian.
      // Nota: ++ctr[i] retorna o valor ANTES da truncagem a 8 bits,
      // então usamos ctr[i]++ (sem checar o retorno) e testamos ctr[i]
      // depois, que já reflete o valor truncado corretamente.
      for (int i = 15; i >= 0; i--) {
        ctr[i]++;
        if (ctr[i] != 0) break;
      }
    }
    return out;
  }
}
