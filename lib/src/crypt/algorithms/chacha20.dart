import 'dart:typed_data';

import 'poly1305_mac.dart';

// ---------------------------------------------------------------------------
// ChaCha20 — RFC 8439
// ---------------------------------------------------------------------------

/// Executa a função de bloco ChaCha20 e retorna 64 bytes de keystream.
///
/// - [key]     : 32 bytes (256 bits)
/// - [counter] : valor inicial do contador (1 para dados, 0 para gerar chave Poly1305)
/// - [nonce]   : 12 bytes (96 bits)
Uint8List chacha20Block(Uint8List key, int counter, Uint8List nonce) {
  assert(key.length == 32, 'ChaCha20: key deve ter 32 bytes');
  assert(nonce.length == 12, 'ChaCha20: nonce deve ter 12 bytes');

  final state = Uint32List(16);

  // Constantes "expand 32-byte k"
  state[0] = 0x61707865;
  state[1] = 0x3320646e;
  state[2] = 0x79622d32;
  state[3] = 0x6b206574;

  // Chave (8 palavras de 32 bits, little-endian)
  final keyView = ByteData.sublistView(key);
  for (int i = 0; i < 8; i++) {
    state[4 + i] = keyView.getUint32(i * 4, Endian.little);
  }

  // Contador
  state[12] = counter;

  // Nonce (3 palavras de 32 bits, little-endian)
  final nonceView = ByteData.sublistView(nonce);
  for (int i = 0; i < 3; i++) {
    state[13 + i] = nonceView.getUint32(i * 4, Endian.little);
  }

  // Copia do estado de trabalho
  final working = Uint32List.fromList(state);

  // 20 rounds (10 colunas + 10 diagonais)
  for (int i = 0; i < 10; i++) {
    // Rounds de coluna
    _quarterRound(working, 0, 4, 8, 12);
    _quarterRound(working, 1, 5, 9, 13);
    _quarterRound(working, 2, 6, 10, 14);
    _quarterRound(working, 3, 7, 11, 15);
    // Rounds diagonais
    _quarterRound(working, 0, 5, 10, 15);
    _quarterRound(working, 1, 6, 11, 12);
    _quarterRound(working, 2, 7, 8, 13);
    _quarterRound(working, 3, 4, 9, 14);
  }

  // Soma o estado original ao estado de trabalho e serializa em little-endian
  final block = Uint8List(64);
  final blockView = ByteData.sublistView(block);
  for (int i = 0; i < 16; i++) {
    final value = (working[i] + state[i]) & 0xffffffff;
    blockView.setUint32(i * 4, value, Endian.little);
  }

  return block;
}

/// Operação quarter-round do ChaCha20.
void _quarterRound(Uint32List s, int a, int b, int c, int d) {
  s[a] = (s[a] + s[b]) & 0xffffffff;
  s[d] ^= s[a];
  s[d] = (s[d] << 16) | (s[d] >>> 16);

  s[c] = (s[c] + s[d]) & 0xffffffff;
  s[b] ^= s[c];
  s[b] = (s[b] << 12) | (s[b] >>> 20);

  s[a] = (s[a] + s[b]) & 0xffffffff;
  s[d] ^= s[a];
  s[d] = (s[d] << 8) | (s[d] >>> 24);

  s[c] = (s[c] + s[d]) & 0xffffffff;
  s[b] ^= s[c];
  s[b] = (s[b] << 7) | (s[b] >>> 25);
}

/// Cifra ou decifra [input] usando ChaCha20 (operação XOR com keystream).
///
/// Encrypt e decrypt são a mesma operação em stream ciphers.
List<int> chacha20Encrypt(
  Uint8List key,
  int counter,
  Uint8List nonce,
  List<int> input,
) {
  final length = input.length;
  final output =
      (input is Uint8List) ? Uint8List(length) : List<int>.filled(length, 0);

  final numBlocks = (length + 63) ~/ 64;

  for (int blockNum = 0; blockNum < numBlocks; blockNum++) {
    final keyStream = chacha20Block(key, counter + blockNum, nonce);
    final start = blockNum * 64;
    final end = (start + 64 <= length) ? start + 64 : length;

    for (int i = start; i < end; i++) {
      output[i] = input[i] ^ keyStream[i - start];
    }
  }

  return output;
}

// ---------------------------------------------------------------------------
// Poly1305 Key Generation e Tag
// ---------------------------------------------------------------------------

/// Gera a chave Poly1305 usando ChaCha20 com contador 0 (conforme RFC 8439 §2.6).
Uint8List poly1305KeyGen(Uint8List key, Uint8List nonce) {
  final block = chacha20Block(key, 0, nonce);
  return Uint8List.sublistView(block, 0, 32);
}

/// Calcula a tag Poly1305 para [ciphertext] e [aad] usando [polyKey].
///
/// Segue o formato de entrada do RFC 8439 §2.8:
/// AAD | pad(AAD) | ciphertext | pad(ciphertext) | len(AAD) | len(ciphertext)
Uint8List calculateTag(List<int> ciphertext, Uint8List aad, Uint8List polyKey) {
  final mac = Poly1305Mac(polyKey);

  if (aad.isNotEmpty) {
    mac.update(aad);
    mac.update(_pad16(aad.length));
  }

  if (ciphertext.isNotEmpty) {
    mac.update(ciphertext);
    mac.update(_pad16(ciphertext.length));
  }

  // Comprimentos em little-endian de 8 bytes cada
  mac.update(_uint64LE(aad.length));
  mac.update(_uint64LE(ciphertext.length));

  return mac.finish();
}

// ---------------------------------------------------------------------------
// Utilitários
// ---------------------------------------------------------------------------

/// Retorna bytes de padding para alinhar [length] ao múltiplo de 16.
Uint8List _pad16(int length) {
  final rem = length % 16;
  return rem == 0 ? Uint8List(0) : Uint8List(16 - rem);
}

/// Serializa [value] como uint64 little-endian em 8 bytes.
Uint8List _uint64LE(int value) {
  final bytes = Uint8List(8);
  ByteData.sublistView(bytes).setUint64(0, value, Endian.little);
  return bytes;
}

/// Comparação em tempo constante entre dois byte arrays.
///
/// Previne ataques de timing ao comparar tags de autenticação.
bool constantTimeCompare(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  int diff = 0;
  for (int i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
