import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('snippets bilíngues de HelperUtil', () {
    test('texto, números e calendário', () {
      expect(HelperUtil.countWords('Flutter is productive'), 3);
      expect(
        HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>'),
        'Hello World',
      );
      expect(
          HelperUtil.capitalizeWords('hello dart world'), 'Hello Dart World');
      expect(HelperUtil.removeNonNumeric('R\$ 1.234,56'), '123456');
      expect(HelperUtil.calculatePercentage(25, 200), 12.5);
      expect(
        () => HelperUtil.calculatePercentage(10, 0),
        throwsArgumentError,
      );
      expect(
        HelperUtil.daysBetween(DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
        364,
      );
      expect(
        HelperUtil.businessDaysBetween(
          DateTime(2026, 6, 1),
          DateTime(2026, 6, 30),
        ),
        22,
      );
      expect(HelperUtil.isLeapYear(2024), isTrue);
      expect(HelperUtil.isValidDate('29/02/2025'), isFalse);
    });

    test('UUIDs documentam formato e compatibilidade determinística', () {
      const namespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
      final v3 = HelperUtil.generateUUIDv3(namespace, 'entity-name');
      final v5 = HelperUtil.generateUUIDv5(namespace, 'entity-name');

      expect(v3, matches(RegExp(r'^[0-9a-f-]{14}3[0-9a-f-]{21}$')));
      expect(v5, matches(RegExp(r'^[0-9a-f-]{14}5[0-9a-f-]{21}$')));
      expect(v3, HelperUtil.generateUUIDv3(namespace, 'entity-name'));
      expect(v5, HelperUtil.generateUUIDv5(namespace, 'entity-name'));
    });

    test('JWT é somente inspecionado, sem inferir autenticação', () {
      const token = 'eyJhbGciOiJub25lIn0.'
          'eyJzdWIiOiIxMjMiLCJyb2xlIjoiYWRtaW4iLCJleHAiOjQxMDI0NDQ4MDB9.';

      expect(HelperUtil.decodeJWT(token)?['sub'], '123');
      expect(HelperUtil.isJwtExpired(token), isFalse);
      expect(HelperUtil.hasJwtClaim(token, 'role'), isTrue);
      expect(HelperUtil.getJwtClaim(token, 'role'), 'admin');
    });

    test('compatibilidade de senha e PIX', () {
      final stored = HelperUtil.encryptPassword(
        'demo-password',
        'demo-application-key',
        'demo-salt',
      );

      expect(
        HelperUtil.validatePassword(
          'demo-password',
          'demo-application-key',
          stored,
        ),
        isTrue,
      );
      expect(HelperUtil.validatePixKey('+5511912345678'), 'Celular');
      expect(HelperUtil.maskPixKey('99286479174'), '992.***.***-74');
      expect(HelperUtil.getDeviceInfo(), containsPair('isWeb', isA<bool>()));
    });
  });
}
