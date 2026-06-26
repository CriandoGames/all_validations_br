import 'dart:math';
import 'dart:typed_data';

/// Implementação do MAC Poly1305 conforme RFC 8439.
///
/// Poly1305 é um autenticador de mensagem de uso único baseado em aritmética
/// modular no campo primo p = 2¹³⁰ − 5. É utilizado em conjunto com
/// ChaCha20 para fornecer criptografia autenticada (AEAD).
class Poly1305Mac {
  /// Primo do campo: 2¹³⁰ − 5.
  static final BigInt _p = (BigInt.one << 130) - BigInt.from(5);

  /// Módulo para o acumulador: 2¹²⁸.
  static final BigInt _accMod = BigInt.one << 128;

  static const int _blockSize = 16;

  final BigInt _r;
  final BigInt _s;
  final Uint8List _buffer;

  int _bufferIndex = 0;
  bool _finished = false;
  BigInt _acc = BigInt.zero;

  /// Cria uma instância de [Poly1305Mac] com a [key] de 32 bytes fornecida.
  ///
  /// Os primeiros 16 bytes formam `r` (clampeado) e os últimos 16 bytes formam `s`.
  Poly1305Mac(Uint8List key)
      : _buffer = Uint8List(_blockSize),
        _r = _leBytesToBigInt(_clampR(Uint8List.fromList(key.sublist(0, 16)))),
        _s = _leBytesToBigInt(key.sublist(16, 32));

  /// Alimenta [data] no MAC. Pode ser chamado múltiplas vezes.
  ///
  /// Lança [StateError] se chamado após [finish].
  void update(List<int> data) {
    if (_finished) {
      throw StateError('Poly1305Mac já foi finalizado.');
    }

    int offset = 0;
    int remaining = data.length;

    // Completa bloco pendente no buffer
    if (_bufferIndex > 0) {
      final toCopy = min(_blockSize - _bufferIndex, remaining);
      _buffer.setRange(_bufferIndex, _bufferIndex + toCopy, data);
      _bufferIndex += toCopy;

      if (_bufferIndex == _blockSize) {
        _processBlock(_buffer);
        _bufferIndex = 0;
      }

      offset += toCopy;
      remaining -= toCopy;
    }

    // Processa blocos completos diretamente da entrada
    while (remaining >= _blockSize) {
      _processBlock(data.sublist(offset, offset + _blockSize));
      offset += _blockSize;
      remaining -= _blockSize;
    }

    // Armazena bytes restantes no buffer
    if (remaining > 0) {
      _buffer.setRange(0, remaining, data, offset);
      _bufferIndex = remaining;
    }
  }

  /// Finaliza o cálculo do MAC e retorna a tag de 16 bytes.
  ///
  /// Lança [StateError] se chamado mais de uma vez.
  Uint8List finish() {
    if (_finished) {
      throw StateError('Poly1305Mac já foi finalizado.');
    }

    // Processa bloco final se houver dados no buffer
    if (_bufferIndex > 0) {
      _processBlock(_buffer.sublist(0, _bufferIndex));
    }

    _acc = (_acc + _s) % _accMod;
    _finished = true;

    return _bigIntToLeBytes(_acc, 16);
  }

  // ---------------------------------------------------------------------------
  // Privados
  // ---------------------------------------------------------------------------

  void _processBlock(List<int> block) {
    BigInt n = _leBytesToBigInt(block);

    // Bloco completo: adiciona o bit 2¹²⁸; bloco parcial: adiciona 2^(8*len)
    if (block.length == _blockSize) {
      n += _accMod;
    } else {
      n += BigInt.one << (8 * block.length);
    }

    _acc = ((_acc + n) % _p * _r) % _p;
  }

  /// Aplica o clamping nos 16 bytes de `r` conforme a especificação RFC 8439.
  static Uint8List _clampR(Uint8List r) {
    r[3] &= 15;
    r[7] &= 15;
    r[11] &= 15;
    r[15] &= 15;
    r[4] &= 252;
    r[8] &= 252;
    r[12] &= 252;
    return r;
  }

  /// Converte bytes little-endian em [BigInt].
  static BigInt _leBytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result |= BigInt.from(bytes[i]) << (8 * i);
    }
    return result;
  }

  /// Converte um [BigInt] em bytes little-endian de tamanho [length].
  static Uint8List _bigIntToLeBytes(BigInt number, int length) {
    final bytes = Uint8List(length);
    BigInt temp = number;
    for (int i = 0; i < length; i++) {
      bytes[i] = (temp & BigInt.from(0xff)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }
}
