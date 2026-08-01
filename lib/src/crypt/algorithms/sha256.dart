import 'dart:typed_data';

// ---------------------------------------------------------------------------
// SHA-256 — RFC 6234 / FIPS 180-4
// ---------------------------------------------------------------------------
//
// Implementação pura Dart sem dependências externas.
// Produz um digest de 32 bytes (256 bits).

// Primeiros 32 bits das partes fracionárias das raízes cúbicas dos
// primeiros 64 números primos.
const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

// Primeiros 32 bits das partes fracionárias das raízes quadradas dos
// primeiros 8 números primos — valores iniciais do hash.
const List<int> _h0 = [
  0x6a09e667,
  0xbb67ae85,
  0x3c6ef372,
  0xa54ff53a,
  0x510e527f,
  0x9b05688c,
  0x1f83d9ab,
  0x5be0cd19,
];

// ---------------------------------------------------------------------------
// Rotação circular à direita (32 bits)
// ---------------------------------------------------------------------------
int _rotr32(int x, int n) => ((x >>> n) | (x << (32 - n))) & 0xffffffff;

// ---------------------------------------------------------------------------
// API pública
// ---------------------------------------------------------------------------

/// Calcula o digest SHA-256 de [data] e retorna 32 bytes.
///
/// ```dart
/// final digest = sha256(utf8.encode('hello'));
/// // digest.length == 32
/// ```
Uint8List sha256(List<int> data) {
  // --- 1. Pré-processamento: padding ---
  // Comprimento original em bits
  final bitLength = data.length * 8;

  // Cria lista mutável e adiciona bit '1' (0x80)
  final padded = [...data, 0x80];

  // Padding com zeros até comprimento ≡ 448 mod 512 bits (56 mod 64 bytes)
  while (padded.length % 64 != 56) {
    padded.add(0x00);
  }

  // Comprimento original como uint64 big-endian (8 bytes)
  for (int i = 7; i >= 0; i--) {
    padded.add((bitLength >> (i * 8)) & 0xff);
  }

  // --- 2. Inicializa o estado do hash ---
  final h = List<int>.from(_h0);

  // --- 3. Processa cada bloco de 512 bits (64 bytes) ---
  final numBlocks = padded.length ~/ 64;
  final w = List<int>.filled(64, 0);

  for (int blockIdx = 0; blockIdx < numBlocks; blockIdx++) {
    final offset = blockIdx * 64;

    // Prepara o message schedule (64 palavras de 32 bits)
    for (int i = 0; i < 16; i++) {
      w[i] = ((padded[offset + i * 4] & 0xff) << 24) |
          ((padded[offset + i * 4 + 1] & 0xff) << 16) |
          ((padded[offset + i * 4 + 2] & 0xff) << 8) |
          (padded[offset + i * 4 + 3] & 0xff);
    }

    for (int i = 16; i < 64; i++) {
      final s0 = _rotr32(w[i - 15], 7) ^
          _rotr32(w[i - 15], 18) ^
          (w[i - 15] >>> 3);
      final s1 = _rotr32(w[i - 2], 17) ^
          _rotr32(w[i - 2], 19) ^
          (w[i - 2] >>> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }

    // Inicializa variáveis de trabalho com o hash atual
    int a = h[0],
        b = h[1],
        c = h[2],
        d = h[3],
        e = h[4],
        f = h[5],
        g = h[6],
        hh = h[7];

    // 64 rounds de compressão
    for (int i = 0; i < 64; i++) {
      final s1 = _rotr32(e, 6) ^ _rotr32(e, 11) ^ _rotr32(e, 25);
      final ch = (e & f) ^ (~e & g) & 0xffffffff;
      final temp1 = (hh + s1 + ch + _k[i] + w[i]) & 0xffffffff;
      final s0 = _rotr32(a, 2) ^ _rotr32(a, 13) ^ _rotr32(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xffffffff;

      hh = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    // Soma o bloco comprimido ao hash corrente
    h[0] = (h[0] + a) & 0xffffffff;
    h[1] = (h[1] + b) & 0xffffffff;
    h[2] = (h[2] + c) & 0xffffffff;
    h[3] = (h[3] + d) & 0xffffffff;
    h[4] = (h[4] + e) & 0xffffffff;
    h[5] = (h[5] + f) & 0xffffffff;
    h[6] = (h[6] + g) & 0xffffffff;
    h[7] = (h[7] + hh) & 0xffffffff;
  }

  // --- 4. Serializa digest em big-endian ---
  final digest = Uint8List(32);
  final view = ByteData.sublistView(digest);
  for (int i = 0; i < 8; i++) {
    view.setUint32(i * 4, h[i], Endian.big);
  }
  return digest;
}
