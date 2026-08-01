/// Regressões da auditoria final de validações após a versão 4.5.1.
library;

import 'dart:io';

import 'package:all_validations_br/all_validations_br.dart';
import 'package:all_validations_br/br_zod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AllValidations.getStateByDDD', () {
    test('é acessível como método estático', () {
      expect(AllValidations.getStateByDDD('11'), BrazilianState.SP);
      expect(AllValidations.getStateByDDD('21'), BrazilianState.RJ);
      expect(AllValidations.getStateByDDD('61'), BrazilianState.DF);
      expect(AllValidations.getStateByDDD('00'), BrazilianState.Unknown);
    });
  });

  group('AllValidations.isCreditCard', () {
    const validCards = [
      '4111111111111111',
      '5555555555554444',
      '378282246310005',
      '6011111111111117',
    ];

    const invalidLuhn = [
      '4111111111111112',
      '5555555555554445',
      '378282246310006',
      '6011111111111118',
    ];

    for (final value in validCards) {
      test('aceita cartão válido: $value', () {
        expect(AllValidations.isCreditCard(value), isTrue);
      });
    }

    for (final value in invalidLuhn) {
      test('rejeita cartão com Luhn inválido: $value', () {
        expect(AllValidations.isCreditCard(value), isFalse);
      });
    }

    test('preserva máscara com espaços e hífens', () {
      expect(AllValidations.isCreditCard('4111-1111-1111-1111'), isTrue);
      expect(AllValidations.isCreditCard('4111 1111 1111 1111'), isTrue);
    });

    test('rejeita letras e conteúdo externo', () {
      expect(
        AllValidations.isCreditCard('abc4111111111111111xyz'),
        isFalse,
      );
    });

    test('rejeita separadores arbitrários ou misturados', () {
      expect(AllValidations.isCreditCard('4111.1111.1111.1111'), isFalse);
      expect(AllValidations.isCreditCard('4111-1111 1111-1111'), isFalse);
    });
  });

  group('Contract DateTime comparisons', () {
    final morning = DateTime(2026, 8, 1, 10);
    final evening = DateTime(2026, 8, 1, 20);
    final sameMoment = DateTime(2026, 8, 1, 10);

    group('equality', () {
      test('areEquals aceita o mesmo instante', () {
        final result =
            Contract().areEquals(morning, sameMoment, 'date', 'diferente');

        expect(result.isValid, isTrue);
      });

      test('areEquals rejeita horários diferentes no mesmo dia', () {
        final result =
            Contract().areEquals(morning, evening, 'date', 'diferente');

        expect(result.isValid, isFalse);
      });

      test('areNotEquals aceita horários diferentes no mesmo dia', () {
        final result =
            Contract().areNotEquals(morning, evening, 'date', 'iguais');

        expect(result.isValid, isTrue);
      });

      test('areNotEquals rejeita o mesmo instante', () {
        final result =
            Contract().areNotEquals(morning, sameMoment, 'date', 'iguais');

        expect(result.isValid, isFalse);
      });
    });

    group('mixed types', () {
      test('areEquals notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().areEquals(
            DateTime(2026),
            '2026-01-01',
            'date',
            'tipos incompatíveis',
          ),
        );
      });

      test('areNotEquals notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().areNotEquals(
            DateTime(2026),
            '2026-01-01',
            'date',
            'tipos incompatíveis',
          ),
        );
      });

      test('isGreaterThan notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().isGreaterThan(
            DateTime(2026),
            '2026-01-01',
            'date',
            'tipos incompatíveis',
          ),
        );
      });

      test('isGreaterOrEqualsThan notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().isGreaterOrEqualsThan(
            DateTime(2026),
            '2026-01-01',
            'date',
            'tipos incompatíveis',
          ),
        );
      });

      test('isLowerThan notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().isLowerThan(
            DateTime(2026),
            '2026-01-01',
            'date',
            'tipos incompatíveis',
          ),
        );
      });

      test('isLowerOrEqualsThan notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().isLowerOrEqualsThan(
            DateTime(2026),
            '2026-01-01',
            'date',
            'tipos incompatíveis',
          ),
        );
      });

      test('isBetween notifica sem lançar TypeError', () {
        _expectMismatchedTypesInvalid(
          () => Contract().isBetween(
            DateTime(2026),
            '2025-01-01',
            DateTime(2027),
            'date',
            'tipos incompatíveis',
          ),
        );
      });
    });
  });

  group('BrZod CNS', () {
    const valid = '700616457492001';

    test('aceita CNS válido', () {
      expect(BrZod().required().cns().build(valid), isNull);
    });

    test('rejeita prefixo e sufixo', () {
      expect(BrZod().required().cns().build('abc${valid}xyz'), isNotNull);
    });

    test('rejeita separador interno', () {
      expect(BrZod().required().cns().build('700616457492-001'), isNotNull);
    });

    test('rejeita espaços externos', () {
      expect(BrZod().required().cns().build(' $valid '), isNotNull);
    });
  });

  group('BrZod phone', () {
    const validValues = [
      '33334444',
      '987654321',
      '1133334444',
      '11987654321',
      '(11) 3333-4444',
      '(11) 98765-4321',
    ];

    const invalidValues = [
      'abc11987654321xyz',
      '(00) 98765-4321',
      '(11) 18765-4321',
      '(11) 68765-4321',
      '11A98765B4321',
      '11987654321 ',
      '+55 11 98765-4321',
    ];

    for (final value in validValues) {
      test('aceita telefone válido: $value', () {
        expect(BrZod().required().phone().build(value), isNull);
      });
    }

    for (final value in invalidValues) {
      test('rejeita telefone inválido: $value', () {
        expect(BrZod().required().phone().build(value), isNotNull);
      });
    }
  });

  group('Email consistency', () {
    const validValues = [
      'user@example.com',
      'user+tag@gmail.com',
      'first.last@sub.example.com',
    ];

    const invalidValues = [
      'a..b@example.com',
      'a@example..com',
      'a@-example.com',
      'a@example-.com',
      '.user@example.com',
      'user.@example.com',
      'user@',
      '@example.com',
      'user example@example.com',
      'user%tag@example.com',
    ];

    for (final value in validValues) {
      test('aceita e-mail válido: $value', () {
        final direct = AllValidations.isEmail(value);
        final contract = Contract().isEmail(value, 'email', 'inválido').isValid;
        final zod = BrZod().required().email().build(value) == null;

        expect(direct, isTrue);
        expect(contract, direct);
        expect(zod, direct);
      });
    }

    for (final value in invalidValues) {
      test('rejeita e-mail inválido: $value', () {
        final direct = AllValidations.isEmail(value);
        final contract = Contract().isEmail(value, 'email', 'inválido').isValid;
        final zod = BrZod().required().email().build(value) == null;

        expect(direct, isFalse);
        expect(contract, direct);
        expect(zod, direct);
      });
    }
  });

  group('BrZod.validate null preservation', () {
    test('custom recebe null original', () {
      dynamic received = 'não executado';
      final schema = BrZod().custom((value) {
        received = value;
        return true;
      });

      BrZod.validate(
        data: {'field': null},
        params: {'field': schema},
      );

      expect(received, isNull);
    });

    test('required continua rejeitando null', () {
      final result = BrZod.validate(
        data: {'field': null},
        params: {'field': BrZod().required()},
      );

      expect(result.isValid, isFalse);
    });

    test('optional continua aceitando null', () {
      final result = BrZod.validate(
        data: {'field': null},
        params: {'field': BrZod().optional().email()},
      );

      expect(result.isValid, isTrue);
    });

    test('campo ausente continua sendo tratado como null', () {
      dynamic received = 'não executado';

      BrZod.validate(
        data: {},
        params: {
          'field': BrZod().custom((value) {
            received = value;
            return true;
          }),
        },
      );

      expect(received, isNull);
    });
  });

  group('Documentation examples', () {
    test('vetor alfanumérico corrigido é válido', () {
      const value = 'AB.1CD.2EF/3GHI-09';

      expect(CnpjAlfanumerico.isValid(value), isTrue);
      expect(AllValidations.isCnpjAlphanumeric(value), isTrue);
      expect(BrZod().required().cnpjAlfa().build(value), isNull);
    });

    test('literais documentados como válidos têm DVs válidos', () {
      const paths = [
        'README.md',
        'doc/AllValidations.md',
        'doc/CnpjAlfanumerico.md',
      ];
      final examples = <String>{};
      final validatorCall = RegExp(
        r"(?:isCnpj|isCnpjAlphanumeric|isValid)\('([^']+)'\).*//\s*true",
      );

      for (final path in paths) {
        final contents = File(path).readAsStringSync();
        examples.addAll(
          validatorCall
              .allMatches(contents)
              .map((match) => match.group(1)!)
              .where(_looksLikeCnpj),
        );
      }

      expect(examples, isNotEmpty);
      for (final value in examples) {
        expect(
          CnpjAlfanumerico.isValid(value),
          isTrue,
          reason: 'O exemplo documentado "$value" precisa ter DVs válidos.',
        );
      }
    });
  });

  group('Public API smoke tests', () {
    test('barrels principais continuam expondo as APIs usadas na auditoria',
        () {
      expect(AllValidations.isCpf('52998224725'), isTrue);
      expect(AllValidations.getStateByDDD('11'), BrazilianState.SP);
      expect(Contract().isTrue(true, 'value', 'erro').isValid, isTrue);
      expect(BrZod().required().email().build('user@example.com'), isNull);
      expect(CnpjAlfanumerico.isValid('12ABC34501DE35'), isTrue);
    });
  });
}

void _expectMismatchedTypesInvalid(
  ContractValidations Function() validation,
) {
  late ContractValidations result;

  expect(() => result = validation(), returnsNormally);
  expect(result.isValid, isFalse);
  expect(result.notifications, hasLength(1));
}

bool _looksLikeCnpj(String value) {
  return RegExp(
    r'^(?:[A-Za-z0-9]{14}|[A-Za-z0-9]{2}\.[A-Za-z0-9]{3}\.[A-Za-z0-9]{3}/[A-Za-z0-9]{4}-\d{2})$',
  ).hasMatch(value);
}
