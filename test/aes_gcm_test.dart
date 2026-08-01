import 'dart:typed_data';

import 'package:all_validations_br/src/crypt/algorithms/aes_core.dart';
import 'package:all_validations_br/src/crypt/algorithms/aes_gcm.dart';
import 'package:all_validations_br/src/crypt/models/crypt_exception.dart';
import 'package:all_validations_br/src/crypt/models/encrypted_payload.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Utilitários
// ---------------------------------------------------------------------------

Uint8List _hex(String s) {
  final src = s.replaceAll(' ', '');
  final out = Uint8List(src.length ~/ 2);
  for (int i = 0; i < out.length; i++) {
    out[i] = int.parse(src.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

String _toHex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

AesGcm _gcm({
  required String key,
  required String iv,
  String aad = '',
}) =>
    AesGcm(
      key: _hex(key),
      nonce: _hex(iv),
      aad: aad.isEmpty ? Uint8List(0) : _hex(aad),
    );

EncryptedPayload _tamper(
  EncryptedPayload p, {
  Uint8List? ciphertext,
  Uint8List? tag,
}) =>
    EncryptedPayload(
      algorithm: p.algorithm,
      ciphertext: ciphertext ?? p.ciphertext,
      key: p.key,
      tag: tag ?? p.tag,
      nonce: p.nonce,
      aad: p.aad,
    );

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // AES Core — FIPS 197 (bloco único, verifica S-box + key schedule)
  // =========================================================================
  group('AES Core — FIPS 197', () {
    test('AES-128 ECB — Apêndice B', () {
      final key   = _hex('2b7e151628aed2a6abf7158809cf4f3c');
      final block = _hex('3243f6a8885a308d313198a2e0370734');
      final ek = aesExpandKey(key);
      expect(_toHex(aesEncryptBlock(block, ek)),
             '3925841d02dc09fbdc118597196a0b32');
    });

    test('AES-256 ECB — Apêndice C.3', () {
      final key   = _hex('000102030405060708090a0b0c0d0e0f'
                         '101112131415161718191a1b1c1d1e1f');
      final block = _hex('00112233445566778899aabbccddeeff');
      final ek = aesExpandKey(key);
      expect(_toHex(aesEncryptBlock(block, ek)),
             '8ea2b7ca516745bfeafc49904b496089');
    });

    test('AES-128 ECB — roundtrip decifra', () {
      final key   = _hex('2b7e151628aed2a6abf7158809cf4f3c');
      final plain = _hex('3243f6a8885a308d313198a2e0370734');
      final ek    = aesExpandKey(key);
      expect(_toHex(aesDecryptBlock(aesEncryptBlock(plain, ek), ek)),
             _toHex(plain));
    });

    test('AES-256 ECB — roundtrip decifra', () {
      final key   = _hex('000102030405060708090a0b0c0d0e0f'
                         '101112131415161718191a1b1c1d1e1f');
      final plain = _hex('00112233445566778899aabbccddeeff');
      final ek    = aesExpandKey(key);
      expect(_toHex(aesDecryptBlock(aesEncryptBlock(plain, ek), ek)),
             _toHex(plain));
    });

    test('aesNumRounds — AES-128 = 10', () {
      expect(aesNumRounds(aesExpandKey(Uint8List(16))), 10);
    });

    test('aesNumRounds — AES-256 = 14', () {
      expect(aesNumRounds(aesExpandKey(Uint8List(32))), 14);
    });
  });

  // =========================================================================
  // AES-GCM — NIST SP 800-38D (vetores verificados com Python cryptography)
  // =========================================================================
  group('AES-GCM — NIST SP 800-38D', () {

    // ── TC 1 ─ K=0^16, IV=0^12, P='', A='' ─────────────────────────────────
    test('TC1 — AES-128-GCM, plaintext vazio, sem AAD', () {
      final gcm = _gcm(
        key: '00000000000000000000000000000000',
        iv:  '000000000000000000000000',
      );
      final p = gcm.encrypt([]);
      expect(p.ciphertext, isEmpty);
      expect(_toHex(p.tag), '58e2fccefa7e3061367f1d57a4e7455a');
    });

    // ── TC 2 ─ K=0^16, IV=0^12, P=0^16, A='' ───────────────────────────────
    test('TC2 — AES-128-GCM, P=0^16, sem AAD', () {
      final gcm = _gcm(
        key: '00000000000000000000000000000000',
        iv:  '000000000000000000000000',
      );
      final p = gcm.encrypt(Uint8List(16));
      expect(_toHex(p.ciphertext), '0388dace60b6a392f328c2b971b2fe78');
      expect(_toHex(p.tag),        'ab6e47d42cec13bdf53a67b21257bddf');
    });

    // ── TC 3 ─ AES-256-GCM com AAD — NIST Test Vector 4 ────────────────────
    test('TC3 — AES-256-GCM com AAD (NIST Vector 4)', () {
      final gcm = _gcm(
        key: 'feffe9928665731c6d6a8f9467308308'
             'feffe9928665731c6d6a8f9467308308',
        iv:  'cafebabefacedbaddecaf888',
        aad: 'feedfacedeadbeeffeedfacedeadbeefabaddad2',
      );
      final pt = _hex(
        'd9313225f88406e5a55909c5aff5269a'
        '86a7a9531534f7da2e4c303d8a318a72'
        '1c3c0c95956809532fcf0e2449a6b525'
        'b16aedf5aa0de657ba637b391aafd255',
      );
      final p = gcm.encrypt(pt);
      expect(_toHex(p.ciphertext),
        '522dc1f099567d07f47f37a32a84427d'
        '643a8cdcbfe5c0c97598a2bd2555d1aa'
        '8cb08e48590dbb3da7b08b1056828838'
        'c5f61e6393ba7a0abcc9f662898015ad',
      );
      expect(_toHex(p.tag), '2df7cd675b4f09163b41ebf980a7f638');
    });

    // ── Roundtrips ──────────────────────────────────────────────────────────
    test('roundtrip — AES-128-GCM, 100 bytes', () {
      final gcm = _gcm(
        key: '1234567890abcdef1234567890abcdef',
        iv:  '000000000000000000000001',
      );
      final plain = List<int>.generate(100, (i) => i % 256);
      expect(gcm.decrypt(gcm.encrypt(plain)), equals(plain));
    });

    test('roundtrip — AES-256-GCM, bloco não alinhado (63 bytes)', () {
      final gcm = _gcm(
        key: 'deadbeefdeadbeefdeadbeefdeadbeef'
             'deadbeefdeadbeefdeadbeefdeadbeef',
        iv:  'cafebabe00000000cafebabe',
      );
      final plain = List<int>.generate(63, (i) => i);
      expect(gcm.decrypt(gcm.encrypt(plain)), equals(plain));
    });

    test('roundtrip — AES-128-GCM, plaintext vazio', () {
      final gcm = _gcm(
        key: '00000000000000000000000000000001',
        iv:  '000000000000000000000000',
      );
      final payload = gcm.encrypt([]);
      expect(gcm.decrypt(payload), isEmpty);
    });

    test('roundtrip — AES-256-GCM com AAD, 200 bytes', () {
      final gcm = AesGcm(
        key:   Uint8List(32),
        nonce: Uint8List(12),
        aad:   Uint8List.fromList(List.generate(20, (i) => i)),
      );
      final plain = List<int>.generate(200, (i) => i % 251);
      expect(gcm.decrypt(gcm.encrypt(plain)), equals(plain));
    });

    // ── Detecção de adulteração ──────────────────────────────────────────────
    test('tag adulterada → CryptException', () {
      final gcm = _gcm(
        key: '00000000000000000000000000000000',
        iv:  '000000000000000000000000',
      );
      final p   = gcm.encrypt([1, 2, 3]);
      final bad = _tamper(p, tag: Uint8List.fromList(p.tag)..[0] ^= 0xff);
      expect(() => gcm.decrypt(bad), throwsA(isA<CryptException>()));
    });

    test('ciphertext adulterado → CryptException', () {
      final gcm = _gcm(
        key: '00000000000000000000000000000000',
        iv:  '000000000000000000000000',
      );
      final p   = gcm.encrypt([1, 2, 3, 4, 5]);
      final bad = _tamper(p, ciphertext: Uint8List.fromList(p.ciphertext)..[2] ^= 0x42);
      expect(() => gcm.decrypt(bad), throwsA(isA<CryptException>()));
    });

    test('chave errada → CryptException', () {
      final gcm1 = _gcm(
        key: '00000000000000000000000000000000',
        iv:  '000000000000000000000000',
      );
      final gcm2 = _gcm(
        key: '00000000000000000000000000000001',
        iv:  '000000000000000000000000',
      );
      expect(() => gcm2.decrypt(gcm1.encrypt([42, 43, 44])),
             throwsA(isA<CryptException>()));
    });

    // ── Validações de parâmetros ─────────────────────────────────────────────
    test('chave inválida (24 bytes) → ArgumentError', () {
      expect(
        () => AesGcm(key: Uint8List(24), nonce: Uint8List(12), aad: Uint8List(0))
              .encrypt([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('nonce inválido (16 bytes) → ArgumentError', () {
      expect(
        () => AesGcm(key: Uint8List(16), nonce: Uint8List(16), aad: Uint8List(0))
              .encrypt([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    // ── Serialização JSON ────────────────────────────────────────────────────
    test('toJson → algorithm = "aes-gcm"', () {
      final gcm = _gcm(
        key: 'aabbccddeeff00112233445566778899',
        iv:  'aabbccddeeff001122334455',
      );
      final payload = gcm.encrypt([1, 2, 3]);
      expect(payload.toJson()['algorithm'], 'aes-gcm');
    });

    test('toJson / fromJson — roundtrip completo', () {
      final gcm = _gcm(
        key: 'aabbccddeeff00112233445566778899',
        iv:  'aabbccddeeff001122334455',
      );
      final plain   = List<int>.generate(32, (i) => i);
      final payload = gcm.encrypt(plain);
      final json    = payload.toJson();

      final restored = gcm.decrypt(EncryptedPayload.fromJson(json));
      expect(restored, equals(plain));
    });

    test('toBase64 / fromBase64 — roundtrip', () {
      final gcm = _gcm(
        key: '0f1e2d3c4b5a69788796a5b4c3d2e1f0',
        iv:  '112233445566778899aabbcc',
      );
      final plain   = List<int>.generate(48, (i) => i);
      final payload = gcm.encrypt(plain);
      final b64     = payload.toBase64();

      final restored = gcm.decrypt(EncryptedPayload.fromBase64(b64));
      expect(restored, equals(plain));
    });
  });
}
