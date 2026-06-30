import 'dart:typed_data';

import 'sha256.dart';

// ---------------------------------------------------------------------------
// HMAC-SHA256 — RFC 2104
// ---------------------------------------------------------------------------
//
// HMAC(K, m) = SHA256((K' ⊕ opad) || SHA256((K' ⊕ ipad) || m))
//
// Onde:
//   K'   = chave com padding ou hashed para 64 bytes (tamanho do bloco SHA-256)
//   ipad = 0x36 repetido 64 vezes
//   opad = 0x5c repetido 64 vezes

const int _blockSize = 64; // tamanho do bloco SHA-256 em bytes

/// Calcula HMAC-SHA256 para [message] usando [key].
///
/// Retorna 32 bytes (256 bits).
///
/// ```dart
/// final tag = hmacSha256(key, utf8.encode('mensagem'));
/// // tag.length == 32
/// ```
Uint8List hmacSha256(List<int> key, List<int> message) {
  // --- 1. Normaliza a chave para exatamente 64 bytes ---
  List<int> normalizedKey;
  if (key.length > _blockSize) {
    // Chave longa: faz hash dela primeiro
    normalizedKey = sha256(key);
  } else {
    normalizedKey = key;
  }

  // Padding com zeros até 64 bytes
  final k = Uint8List(_blockSize);
  for (int i = 0; i < normalizedKey.length; i++) {
    k[i] = normalizedKey[i];
  }

  // --- 2. Calcula ipad e opad ---
  final iKeyPad = Uint8List(_blockSize);
  final oKeyPad = Uint8List(_blockSize);
  for (int i = 0; i < _blockSize; i++) {
    iKeyPad[i] = k[i] ^ 0x36;
    oKeyPad[i] = k[i] ^ 0x5c;
  }

  // --- 3. HMAC = SHA256(opad || SHA256(ipad || message)) ---
  final innerInput = Uint8List(iKeyPad.length + message.length)
    ..setAll(0, iKeyPad)
    ..setAll(iKeyPad.length, message);

  final innerHash = sha256(innerInput);

  final outerInput = Uint8List(oKeyPad.length + innerHash.length)
    ..setAll(0, oKeyPad)
    ..setAll(oKeyPad.length, innerHash);

  return sha256(outerInput);
}

/// Compara dois HMACs em tempo constante para evitar ataques de timing.
///
/// Equivalente ao [constantTimeCompare] do ChaCha20, mas dedicado a MACs.
bool hmacEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  int diff = 0;
  for (int i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
