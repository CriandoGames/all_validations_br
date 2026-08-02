import 'dart:convert';

import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

String createUnsignedJwt(Map<String, dynamic> payload) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  return '${encode({'alg': 'none', 'typ': 'JWT'})}.${encode(payload)}.';
}

void main() {
  group('chave Pix CNPJ', () {
    test('validatePixKey reconhece CNPJ formatado', () {
      expect(
        HelperUtil.validatePixKey('12.345.678/0001-95'),
        'CNPJ',
      );
    });

    test('validatePixKey reconhece CNPJ sem máscara', () {
      expect(
        HelperUtil.validatePixKey('12345678000195'),
        'CNPJ',
      );
    });

    test('validatePixKey rejeita CNPJ inválido', () {
      expect(
        HelperUtil.validatePixKey('12.345.678/0001-96'),
        isNull,
      );
    });

    test('mascara CNPJ', () {
      expect(
        HelperUtil.maskPixKey('12.345.678/0001-95'),
        '12.***.***/****-95',
      );
    });

    test('não devolve entrada desconhecida em texto aberto', () {
      const input = '11999998877';

      final masked = HelperUtil.maskPixKey(input);

      expect(masked, '***');
      expect(masked, isNot(input));
    });

    test('entrada vazia continua vazia', () {
      expect(HelperUtil.maskPixKey(''), '');
    });
  });

  group('isJwtExpired seguro e determinístico', () {
    final reference = DateTime.utc(2030, 1, 1);
    final referenceSeconds = reference.millisecondsSinceEpoch ~/ 1000;

    test('exp igual ao tempo atual está expirado', () {
      final token = createUnsignedJwt({'exp': referenceSeconds});

      expect(
        HelperUtil.isJwtExpired(token, referenceTime: reference),
        isTrue,
      );
    });

    test('exp futuro não está expirado', () {
      final token = createUnsignedJwt({'exp': referenceSeconds + 60});

      expect(
        HelperUtil.isJwtExpired(token, referenceTime: reference),
        isFalse,
      );
    });

    test('exp como string numérica não lança e é aceito', () {
      final token = createUnsignedJwt({'exp': '$referenceSeconds'});

      expect(
        () => HelperUtil.isJwtExpired(token, referenceTime: reference),
        returnsNormally,
      );
      expect(
        HelperUtil.isJwtExpired(token, referenceTime: reference),
        isTrue,
      );
    });

    test('exp como num finito é aceito', () {
      final token = createUnsignedJwt({'exp': referenceSeconds + 60.0});

      expect(
        HelperUtil.isJwtExpired(token, referenceTime: reference),
        isFalse,
      );
    });

    test('exp malformado é tratado como expirado', () {
      final token = createUnsignedJwt({'exp': 'valor-inválido'});

      expect(() => HelperUtil.isJwtExpired(token), returnsNormally);
      expect(HelperUtil.isJwtExpired(token), isTrue);
    });

    test('token sem exp é considerado expirado', () {
      final token = createUnsignedJwt({'sub': '123'});

      expect(HelperUtil.isJwtExpired(token), isTrue);
    });
  });
}
