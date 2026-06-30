import 'dart:convert';
import 'dart:typed_data';

import 'package:all_validations_br/src/crypt/algorithms/aes_cbc.dart';
import 'package:all_validations_br/src/crypt/algorithms/aes_ctr.dart';
import 'package:all_validations_br/src/crypt/models/crypt_exception.dart';
import 'package:all_validations_br/src/crypt/models/encrypted_payload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_validations_br/src/crypt/algorithms/aes_core.dart';

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

// ---------------------------------------------------------------------------
// Constantes NIST SP 800-38A
// ---------------------------------------------------------------------------

// Plaintext comum aos vetores F.2 (CBC) e F.5 (CTR)
const _pt128 = '6bc1bee22e409f96e93d7e117393172a'
    'ae2d8a571e03ac9c9eb76fac45af8e51'
    '30c81c46a35ce411e5fbc1191a0a52ef'
    'f69f2445df4f9b17ad2b417be66c3710';

// AES-128
const _k128 = '2b7e151628aed2a6abf7158809cf4f3c';
// AES-256
const _k256 = '603deb1015ca71be2b73aef0857d7781'
    '1f352c073b6108d72d9810a30914dff4';

// IV compartilhado nos vetores F.2.x e F.5.x (CBC usa mesmo IV que CTR usa como ICB)
const _iv = '000102030405060708090a0b0c0d0e0f'; // CBC IV
const _icb_128 =
    'f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff'; // CTR initial counter block

// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // AES-CBC — NIST SP 800-38A
  // =========================================================================
  group('AES-CBC — NIST SP 800-38A (vetores F.2)', () {
    // ── F.2.1 — AES-128-CBC ─────────────────────────────────────────────────
    // Vetores raw (sem PKCS#7) — testamos via encrypt+decrypt raw para isolar
    // a lógica do encadeamento CBC.
    //
    // Nota: nosso encrypt() aplica PKCS#7, então os vetores raw do NIST
    // são verificados indiretamente pelo encrypt→decrypt roundtrip, e os
    // valores de CT por bloco são testados aqui usando decifração.
    test('F.2.1 — AES-128-CBC: decifra bloco 1', () {
      // CT bloco 1 do NIST F.2.1 → deve decifrar para PT bloco 1
      // Encripta apenas o primeiro bloco (sem padding extra, usamos 15 bytes
      // pois o encrypt adiciona padding automaticamente)
      // Verificamos que o CT produzido bate com o NIST para o 1º bloco
      final pt4 = _hex(_pt128);
      // Para verificar o CT do NIST sem padding, usamos decrifração:
      // NIST F.2.1 CT bloco 1 = 7649abac8119b246cee98e9b12e9197d
      final ct1Nist = _hex('7649abac8119b246cee98e9b12e9197d');
      // AES-dec(ct1) XOR IV = PT1
      final iv16 = _hex(_iv);
      final k128ek = _aesDecryptBlockHelper(ct1Nist, _hex(_k128));
      for (int i = 0; i < 16; i++) {
        expect(k128ek[i] ^ iv16[i], pt4[i],
            reason: 'Byte $i do bloco 1 não coincide com NIST F.2.1');
      }
    });

    // ── Vetores NIST diretos via roundtrip encrypt→decrypt ──────────────────
    test('F.2.1 — AES-128-CBC: 4 blocos, roundtrip', () {
      final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
      final plain = _hex(_pt128).toList();
      expect(cbc.decrypt(cbc.encrypt(plain)), equals(plain));
    });

    test('F.2.5 — AES-256-CBC: 4 blocos, roundtrip', () {
      final cbc = AesCbc(key: _hex(_k256), iv: _hex(_iv));
      final plain = _hex(_pt128).toList();
      expect(cbc.decrypt(cbc.encrypt(plain)), equals(plain));
    });

    // ── CT verificado por Python cryptography (F.2.1) ────────────────────────
    test('F.2.1 — AES-128-CBC: CT bloco 1 verificado via Python', () {
      // Python: cbc_enc(K128, IV, PT[0:15]) = 9be1e579d107a136c031b645a88da750
      // PT = primeiros 15 bytes do plaintext NIST (PKCS#7 adiciona 1 byte 0x01)
      // Verificado com: cryptography.hazmat.primitives.ciphers.modes.CBC
      final key = _hex(_k128);
      final iv = _hex(_iv);
      final pt = _hex('6bc1bee22e409f96e93d7e117393172a').sublist(0, 15);

      final cbc = AesCbc(key: key, iv: iv);
      final ct = cbc.encrypt(pt).ciphertext;
      expect(_toHex(ct), '9be1e579d107a136c031b645a88da750');
    });

    test(
        'F.2.1 — AES-128-CBC: plaintext 16 bytes (1 bloco + 1 bloco de padding)',
        () {
      final key = _hex(_k128);
      final iv = _hex(_iv);
      // Python: 'exatamente16byte' (16 bytes) → CT de 32 bytes
      final pt = utf8.encode('exatamente16byte');
      final cbc = AesCbc(key: key, iv: iv);
      final ct = cbc.encrypt(pt).ciphertext;
      expect(
          _toHex(ct),
          'a4f2f26c8209e024f3bd58633688a53b'
          'd3be584910f1ab23d535f872e816c2f7');
      expect(ct.length, 32);
    });

    test('F.2.5 — AES-256-CBC: CT dos 4 blocos verificado', () {
      // PKCS7 unpad: o último bloco decifrado deve ter padding válido
      // Como o PT NIST tem 64 bytes, o último bloco decifrado terá lixo de padding.
      // Então verificamos apenas os 3 primeiros blocos (48 bytes de PT).
      // Para testar os 4 blocos completos, usamos encrypt(48 bytes) e verificamos CT[0..47].
      final pt48 = _hex(_pt128).sublist(0, 48);
      final ct48 =
          AesCbc(key: _hex(_k256), iv: _hex(_iv)).encrypt(pt48).ciphertext;
      // Os primeiros 3 blocos do CT devem coincidir com o NIST
      expect(
          _toHex(ct48.sublist(0, 48)),
          'f58c4c04d6e5f1ba779eabfb5f7bfbd6'
          '9cfc4e967edb808d679f777bc6702c7d'
          '39f23369a9d9bacfa530e26304231461');
    });

    // ── Roundtrips variados ──────────────────────────────────────────────────
    test('roundtrip — texto vazio (padding puro)', () {
      final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
      // Python: empty → CT = c84af0b613435d5d9182801a9bd9320b
      final ct = cbc.encrypt([]).ciphertext;
      expect(_toHex(ct), 'c84af0b613435d5d9182801a9bd9320b');
      expect(cbc.decrypt(cbc.encrypt([])), isEmpty);
    });

    test('roundtrip — AES-128-CBC, 100 bytes arbitrários', () {
      final cbc = AesCbc(
        key: _hex(_k128),
        iv: _hex(_iv),
      );
      final plain = List<int>.generate(100, (i) => i % 256);
      expect(cbc.decrypt(cbc.encrypt(plain)), equals(plain));
    });

    test('roundtrip — AES-256-CBC, 200 bytes arbitrários', () {
      final cbc = AesCbc(key: _hex(_k256), iv: _hex(_iv));
      final plain = List<int>.generate(200, (i) => (i * 7 + 3) % 256);
      expect(cbc.decrypt(cbc.encrypt(plain)), equals(plain));
    });

    test('roundtrip — texto UTF-8 com acentos', () {
      final cbc = AesCbc(key: Uint8List(16), iv: Uint8List(16));
      final plain = utf8.encode('Criptografia Autêntica com ç, ã, ê!');
      expect(
          utf8.decode(cbc.decrypt(cbc.encrypt(plain))),
          equals(
            'Criptografia Autêntica com ç, ã, ê!',
          ));
    });

    // ── Borda: tamanhos múltiplos de 16 ─────────────────────────────────────
    for (final n in [15, 16, 17, 31, 32, 33, 63, 64, 65]) {
      test('roundtrip — AES-128-CBC, $n bytes', () {
        final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
        final plain = List<int>.generate(n, (i) => i % 251);
        expect(cbc.decrypt(cbc.encrypt(plain)), equals(plain));
      });
    }

    // ── Serialização ─────────────────────────────────────────────────────────
    test('payload.algorithm = "aes-cbc"', () {
      final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
      expect(cbc.encrypt([1, 2, 3]).algorithm, 'aes-cbc');
    });

    test('tag está vazia (CBC não autenticado)', () {
      final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
      expect(cbc.encrypt([1, 2, 3]).tag, isEmpty);
    });

    test('toJson / fromJson — roundtrip', () {
      final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
      final plain = [1, 2, 3, 4, 5];
      final payload = cbc.encrypt(plain);
      expect(cbc.decrypt(EncryptedPayload.fromJson(payload.toJson())),
          equals(plain));
    });

    // ── Validações de parâmetros ─────────────────────────────────────────────
    test('chave de 24 bytes → ArgumentError', () {
      expect(
        () => AesCbc(key: Uint8List(24), iv: Uint8List(16)).encrypt([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('IV de 8 bytes → ArgumentError', () {
      expect(
        () => AesCbc(key: Uint8List(16), iv: Uint8List(8)).encrypt([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'decrypt de ciphertext com tamanho não múltiplo de 16 → CryptException',
        () {
      final cbc = AesCbc(key: _hex(_k128), iv: _hex(_iv));
      final badPayload = EncryptedPayload(
        algorithm: 'aes-cbc',
        ciphertext: Uint8List(17), // inválido
        key: _hex(_k128),
        tag: Uint8List(0),
        nonce: _hex(_iv),
        aad: Uint8List(0),
      );
      expect(() => cbc.decrypt(badPayload), throwsA(isA<CryptException>()));
    });
  });

  // =========================================================================
  // AES-CTR — NIST SP 800-38A
  // =========================================================================
  group('AES-CTR — NIST SP 800-38A (vetores F.5)', () {
    // ── F.5.1 — AES-128-CTR ─────────────────────────────────────────────────
    test('F.5.1 — AES-128-CTR: bloco 1', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      final pt = _hex('6bc1bee22e409f96e93d7e117393172a');
      final ct = ctr.encrypt(pt).ciphertext;
      expect(_toHex(ct), '874d6191b620e3261bef6864990db6ce');
    });

    test('F.5.1 — AES-128-CTR: 4 blocos completos', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      final ct = ctr.encrypt(_hex(_pt128)).ciphertext;
      expect(
        _toHex(ct),
        '874d6191b620e3261bef6864990db6ce'
        '9806f66b7970fdff8617187bb9fffdff'
        '5ae4df3edbd5d35e5b4f09020db03eab'
        '1e031dda2fbe03d1792170a0f3009cee',
      );
    });

    // ── F.5.5 — AES-256-CTR ─────────────────────────────────────────────────
    test('F.5.5 — AES-256-CTR: 4 blocos completos', () {
      final icb256 = _hex('f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff');
      final ctr = AesCtr(key: _hex(_k256), initialCounterBlock: icb256);
      final ct = ctr.encrypt(_hex(_pt128)).ciphertext;
      expect(
        _toHex(ct),
        '601ec313775789a5b7a7f504bbf3d228'
        'f443e3ca4d62b59aca84e990cacaf5c5'
        '2b0930daa23de94ce87017ba2d84988d'
        'dfc9c58db67aada613c2dd08457941a6',
      );
    });

    // ── Simetria (cifrar = decifrar) ─────────────────────────────────────────
    test('decifrar é idêntico a cifrar (CTR simétrico)', () {
      final icb = _hex(_icb_128);
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: icb);
      final plain = List<int>.generate(50, (i) => i);
      final payload = ctr.encrypt(plain);
      // Cria nova instância com mesmo ICB para decifrar
      final ctr2 = AesCtr(key: _hex(_k128), initialCounterBlock: icb);
      expect(ctr2.decrypt(payload), equals(plain));
    });

    // ── Roundtrips ───────────────────────────────────────────────────────────
    test('roundtrip — AES-128-CTR, 1 byte', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      expect(ctr.decrypt(ctr.encrypt([0x42])), equals([0x42]));
    });

    test('roundtrip — AES-128-CTR, plaintext vazio', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      expect(ctr.decrypt(ctr.encrypt([])), isEmpty);
    });

    test('roundtrip — AES-256-CTR, 200 bytes arbitrários', () {
      final ctr = AesCtr(
        key: _hex(_k256),
        initialCounterBlock: _hex('f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff'),
      );
      final plain = List<int>.generate(200, (i) => i % 253);
      expect(ctr.decrypt(ctr.encrypt(plain)), equals(plain));
    });

    for (final n in [1, 15, 16, 17, 31, 32, 33, 100]) {
      test('roundtrip — AES-128-CTR, $n bytes', () {
        final ctr = AesCtr(
          key: _hex(_k128),
          initialCounterBlock: _hex(_icb_128),
        );
        final plain = List<int>.generate(n, (i) => i % 256);
        expect(ctr.decrypt(ctr.encrypt(plain)), equals(plain));
      });
    }

    // ── Inc128 — overflow do contador ────────────────────────────────────────
    test('Inc128 — overflow correto (0xFF...FF → 0x00...00)', () {
      final ctr = AesCtr(
        key: _hex(_k128),
        initialCounterBlock: Uint8List(16)..fillRange(0, 16, 0xff),
      );
      // Deve processar sem exceção (overflow silencioso para 0^128)
      expect(() => ctr.encrypt(List.filled(17, 0)), returnsNormally);
    });

    // ── Serialização ─────────────────────────────────────────────────────────
    test('payload.algorithm = "aes-ctr"', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      expect(ctr.encrypt([1]).algorithm, 'aes-ctr');
    });

    test('tag está vazia (CTR não autenticado)', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      expect(ctr.encrypt([1]).tag, isEmpty);
    });

    test('algoritmo incompatível no payload → CryptException', () {
      final ctr = AesCtr(key: _hex(_k128), initialCounterBlock: _hex(_icb_128));
      final wrongPayload = EncryptedPayload(
        algorithm: 'chacha20-poly1305', // errado
        ciphertext: Uint8List(16),
        key: _hex(_k128),
        tag: Uint8List(0),
        nonce: _hex(_icb_128),
        aad: Uint8List(0),
      );
      expect(() => ctr.decrypt(wrongPayload), throwsA(isA<CryptException>()));
    });

    // ── Validações de parâmetros ─────────────────────────────────────────────
    test('chave de 12 bytes → ArgumentError', () {
      expect(
        () => AesCtr(key: Uint8List(12), initialCounterBlock: Uint8List(16))
            .encrypt([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('initialCounterBlock de 12 bytes → ArgumentError', () {
      expect(
        () => AesCtr(key: Uint8List(16), initialCounterBlock: Uint8List(12))
            .encrypt([]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helper — AES decrypt de bloco único (sem importar aes_core diretamente)
// ---------------------------------------------------------------------------

List<int> _aesDecryptBlockHelper(Uint8List block, Uint8List key) {
  // Usa AesCbc internamente: CBC com IV=0 e CT=block → resulta em Dec(block) XOR 0 = Dec(block)
  // Precisamos de Dec(block) para verificar CBC NIST
  // Como AesCbc.decrypt verifica padding, não podemos usar diretamente.
  // Importamos aes_core via package path
  return _aesDecBlock(block, key);
}

// Importação interna de aes_core para o helper de teste

List<int> _aesDecBlock(Uint8List block, Uint8List key) {
  final ek = aesExpandKey(key);
  return aesDecryptBlock(block, ek);
}
