import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:all_validations_br/src/crypt/algorithms/sha256.dart';
import 'package:all_validations_br/src/crypt/algorithms/hmac_sha256.dart';

// ---------------------------------------------------------------------------
// Utilitários
// ---------------------------------------------------------------------------

Uint8List _fromHex(String hex) {
  final result = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}

String _toHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  // -------------------------------------------------------------------------
  // SHA-256 — vetores NIST (FIPS 180-4)
  // -------------------------------------------------------------------------
  group('SHA-256', () {
    test('vetor NIST 1 — string vazia', () {
      expect(
        _toHex(sha256([])),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('vetor NIST 2 — "abc"', () {
      expect(
        _toHex(sha256(utf8.encode('abc'))),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test(
        'vetor NIST 3 — "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"',
        () {
      const msg = 'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq';
      expect(
        _toHex(sha256(utf8.encode(msg))),
        '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
      );
    });

    test('vetor NIST 4 — "a" × 1.000.000', () {
      final msg = List<int>.filled(1000000, 0x61);
      expect(
        _toHex(sha256(msg)),
        'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0',
      );
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('digest tem sempre 32 bytes', () {
      expect(sha256([]).length, 32);
      expect(sha256(utf8.encode('x')).length, 32);
      expect(sha256(List.filled(100, 0)).length, 32);
    });

    test('determinístico', () {
      final d1 = sha256(utf8.encode('mesmo texto'));
      final d2 = sha256(utf8.encode('mesmo texto'));
      expect(d1, equals(d2));
    });

    test('mensagens diferentes produzem digests diferentes', () {
      final d1 = sha256(utf8.encode('hello'));
      final d2 = sha256(utf8.encode('world'));
      expect(d1, isNot(equals(d2)));
    });

    // Bordas de padding (o bloco SHA-256 é de 64 bytes)
    test('mensagem de 55 bytes — borda inferior do padding', () {
      expect(sha256(List.filled(55, 0x61)).length, 32);
    });

    test('mensagem de 56 bytes — cruza o bloco de padding', () {
      expect(sha256(List.filled(56, 0x61)).length, 32);
    });

    test('mensagem de 64 bytes — exatamente um bloco', () {
      expect(sha256(List.filled(64, 0x61)).length, 32);
    });

    test('mensagem de 128 bytes — dois blocos', () {
      expect(sha256(List.filled(128, 0x61)).length, 32);
    });

    test('dados binários arbitrários — idempotente', () {
      final data = List<int>.generate(256, (i) => i);
      final d1 = sha256(data);
      expect(sha256(data), equals(d1));
    });
  });

  // -------------------------------------------------------------------------
  // HMAC-SHA256 — vetores RFC 4231
  // -------------------------------------------------------------------------
  group('HMAC-SHA256', () {
    // Test Case 1
    test('RFC 4231 — caso 1', () {
      final key = _fromHex('0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b');
      final data = utf8.encode('Hi There');
      expect(
        _toHex(hmacSha256(key, data)),
        'b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7',
      );
    });

    // Test Case 2
    test('RFC 4231 — caso 2', () {
      final key = utf8.encode('Jefe');
      final data = utf8.encode('what do ya want for nothing?');
      expect(
        _toHex(hmacSha256(key, data)),
        '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843',
      );
    });

    // Test Case 3
    test('RFC 4231 — caso 3 (dados 0xdd × 50)', () {
      final key = _fromHex('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
      final data = Uint8List(50)..fillRange(0, 50, 0xdd);
      expect(
        _toHex(hmacSha256(key, data)),
        '773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe',
      );
    });

    // Test Case 4
    test('RFC 4231 — caso 4 (dados 0xcd × 50)', () {
      final key =
          _fromHex('0102030405060708090a0b0c0d0e0f10111213141516171819');
      final data = Uint8List(50)..fillRange(0, 50, 0xcd);
      expect(
        _toHex(hmacSha256(key, data)),
        '82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b',
      );
    });

    // Test Case 6 — chave maior que o bloco (131 bytes)
    test('RFC 4231 — caso 6 (chave > bloco)', () {
      final key = Uint8List(131)..fillRange(0, 131, 0xaa);
      final data =
          utf8.encode('Test Using Larger Than Block-Size Key - Hash Key First');
      expect(
        _toHex(hmacSha256(key, data)),
        '60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54',
      );
    });

    // Test Case 7 — chave e dados ambos maiores que o bloco
    test('RFC 4231 — caso 7 (chave e dados > bloco)', () {
      final key = Uint8List(131)..fillRange(0, 131, 0xaa);
      final data = utf8.encode(
        'This is a test using a larger than block-size key and a larger '
        'than block-size data. The key needs to be hashed before being '
        'used by the HMAC algorithm.',
      );
      expect(
        _toHex(hmacSha256(key, data)),
        '9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2',
      );
    });

    test('resultado tem sempre 32 bytes', () {
      expect(hmacSha256(utf8.encode('k'), utf8.encode('m')).length, 32);
    });

    test('determinístico', () {
      final key = utf8.encode('minha-chave');
      final msg = utf8.encode('minha-mensagem');
      expect(hmacSha256(key, msg), equals(hmacSha256(key, msg)));
    });

    test('chave diferente → MAC diferente', () {
      final msg = utf8.encode('mensagem');
      expect(
        hmacSha256(utf8.encode('chave1'), msg),
        isNot(equals(hmacSha256(utf8.encode('chave2'), msg))),
      );
    });

    test('mensagem diferente → MAC diferente', () {
      final key = utf8.encode('chave');
      expect(
        hmacSha256(key, utf8.encode('msg1')),
        isNot(equals(hmacSha256(key, utf8.encode('msg2')))),
      );
    });

    test('hmacEqual — comparação em tempo constante (igual)', () {
      final a = hmacSha256(utf8.encode('k'), utf8.encode('m'));
      final b = List<int>.from(a);
      expect(hmacEqual(a, b), isTrue);
    });

    test('hmacEqual — comparação em tempo constante (diferente)', () {
      final a = hmacSha256(utf8.encode('k'), utf8.encode('m'));
      final b = List<int>.from(a)..[0] ^= 0xff;
      expect(hmacEqual(a, b), isFalse);
    });

    test('hmacEqual — tamanhos diferentes → false', () {
      expect(hmacEqual([1, 2, 3], [1, 2]), isFalse);
    });
  });
}
