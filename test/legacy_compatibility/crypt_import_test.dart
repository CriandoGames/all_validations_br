import 'dart:convert';
import 'dart:typed_data';

import 'package:all_validations_br/crypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const legacyFixture =
      'eyJhbGdvcml0aG0iOiJjaGFjaGEyMC1wb2x5MTMwNSIsImNpcGhlcnRleHQiOiJVbmpEdnUzWEUzS'
      '1R0MllMTVRxcStoT25zbGZ3UG96SXFsNlMwOXBYb2RQNGlZRFdnZ3B5WHEvZCIsImtleSI6IkFBRU'
      'NBd1FGQmdjSUNRb0xEQTBPRHhBUkVoTVVGUllYR0JrYUd4d2RIaDg9IiwidGFnIjoiUzhsKzRscHZ'
      'kSjhDUWlnWURBS0tMQT09Iiwibm9uY2UiOiJaR1ZtWjJocGFtdHNiVzV2IiwiYWFkIjoiIn0=';

  test('barrel histórico lê e migra payload legado congelado', () {
    final legacy = EncryptedPayload.fromBase64(legacyFixture);
    final migrated = AllCrypto.migrateLegacy(legacy);

    expect(
      AllCrypto.decryptText(migrated.envelope, key: migrated.key),
      'fixture histórica congelada em 2026-08-02',
    );
    expect(migrated.envelope.toJson(), isNot(contains('key')));
  });

  test('barrel histórico expõe envelope v2 seguro', () {
    final key = Uint8List.fromList(List<int>.generate(32, (index) => index));
    final envelope = AllCrypto.encryptText('v2', key: key);
    final restored = CryptEnvelope.fromBase64(envelope.toBase64());

    expect(restored.version, CryptEnvelope.currentVersion);
    expect(restored.toJson(), isNot(contains('key')));
    expect(AllCrypto.decryptText(restored, key: key), 'v2');
  });

  test('barrel histórico rejeita versão de envelope desconhecida', () {
    final encoded = base64.encode(
      utf8.encode(
        jsonEncode({
          'version': 99,
          'algorithm': 'chacha20-poly1305',
          'ciphertext': '',
          'nonce': '',
          'tag': '',
          'aad': '',
        }),
      ),
    );

    expect(
      () => CryptEnvelope.fromBase64(encoded),
      throwsA(isA<ArgumentError>()),
    );
  });
}
