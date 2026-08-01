/// Regressões da segunda auditoria de validações.
///
/// Os casos negativos reproduzem entradas que eram normalizadas ou aceitas
/// indevidamente antes das correções test-first desta auditoria.
library;

import 'dart:io';

import 'package:all_validations_br/all_validations_br.dart';
import 'package:all_validations_br/br_zod.dart';
import 'package:all_validations_br/src/br_zod/validations/generic.dart' as g;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Contract isTrue/isFalse', () {
    test('isTrue aceita true', () {
      final contract =
          Contract().isTrue(true, 'value', 'Deveria ser verdadeiro');

      expect(contract.isValid, isTrue);
      expect(contract.notifications, isEmpty);
    });

    test('isTrue rejeita false', () {
      final contract =
          Contract().isTrue(false, 'value', 'Deveria ser verdadeiro');

      expect(contract.isValid, isFalse);
      expect(contract.notifications, hasLength(1));
    });

    test('isFalse aceita false', () {
      final contract = Contract().isFalse(false, 'value', 'Deveria ser falso');

      expect(contract.isValid, isTrue);
      expect(contract.notifications, isEmpty);
    });

    test('isFalse rejeita true', () {
      final contract = Contract().isFalse(true, 'value', 'Deveria ser falso');

      expect(contract.isValid, isFalse);
      expect(contract.notifications, hasLength(1));
    });

    test('isTrue e isFalse preservam encadeamento', () {
      final contract =
          Contract().isTrue(true, 'a', 'erro').isFalse(false, 'b', 'erro');

      expect(contract.isValid, isTrue);
    });
  });

  group('RG com separadores inválidos', () {
    const validValues = [
      '29.385.462-2',
      '293854622',
      '29.385.462-X',
      '29385462X',
    ];

    const invalidValues = [
      '29a385b462-2',
      '29@385#462-2',
      '29 385 462-2',
      '29/385/462-2',
      '29_385_462-2',
      'prefixo29.385.462-2',
      '29.385.462-2sufixo',
    ];

    for (final value in validValues) {
      test('aceita RG válido: $value', () {
        expect(AllValidations.isRG(value), isTrue);
        expect(AllValidations.validateRG(value).isSuccess, isTrue);
        expect(BrZod().required().rg().build(value), isNull);
      });
    }

    for (final value in invalidValues) {
      test('rejeita RG com separador ou conteúdo arbitrário: $value', () {
        // O ponto não escapado da regex aceitava qualquer caractere.
        expect(AllValidations.isRG(value), isFalse);
        expect(AllValidations.validateRG(value).isFailure, isTrue);
        expect(BrZod().required().rg().build(value), isNotNull);
      });
    }
  });

  group('Documentos com caracteres extras', () {
    group('CPF', () {
      const valid = '529.982.247-25';

      test('aceita CPF conhecido com máscara oficial', () {
        expect(AllValidations.isCpf(valid), isTrue);
        expect(BrZod().required().cpf().build(valid), isNull);
      });

      test('rejeita prefixo e sufixo', () {
        expect(AllValidations.isCpf('abc${valid}xyz'), isFalse);
      });

      test('rejeita letras misturadas', () {
        expect(AllValidations.isCpf('529a982b247c25'), isFalse);
      });

      test('BrZod rejeita caracteres extras', () {
        expect(
          BrZod().required().cpf().build('abc52998224725xyz'),
          isNotNull,
        );
      });

      test('rejeita máscara não oficial', () {
        expect(AllValidations.isCpf('529-982-247.25'), isFalse);
        expect(BrZod().required().cpf().build('529-982-247.25'), isNotNull);
      });
    });

    group('CNPJ', () {
      const valid = '11.222.333/0001-81';

      test('aceita CNPJ conhecido com máscara oficial', () {
        expect(AllValidations.isCnpj(valid), isTrue);
        expect(BrZod().required().cnpj().build(valid), isNull);
      });

      test('rejeita prefixo e sufixo', () {
        expect(AllValidations.isCnpj('abc${valid}xyz'), isFalse);
      });

      test('rejeita letras misturadas em CNPJ numérico', () {
        expect(AllValidations.isCnpj('11A222B333C0001D81'), isFalse);
      });

      test('BrZod rejeita caracteres extras', () {
        expect(
          BrZod().required().cnpj().build('abc11222333000181xyz'),
          isNotNull,
        );
      });

      test('rejeita máscara não oficial', () {
        expect(AllValidations.isCnpj('11-222-333-0001-81'), isFalse);
        expect(
          BrZod().required().cnpj().build('11-222-333-0001-81'),
          isNotNull,
        );
      });
    });

    test('PIS/PASEP preserva a máscara oficial conhecida', () {
      const masked = '123.45678.91-9';
      expect(AllValidations.isPisPasep(masked), isTrue);
      expect(BrZod().required().pisPasep().build(masked), isNull);
    });

    const documents = <String,
        ({
      String valid,
      bool Function(String) direct,
      String? Function(String) zod
    })>{
      'CNH': (
        valid: '84718735264',
        direct: AllValidations.isCnh,
        zod: _validateCnh,
      ),
      'RENAVAM': (
        valid: '95606520941',
        direct: AllValidations.isRenavam,
        zod: _validateRenavam,
      ),
      'PIS/PASEP': (
        valid: '12345678919',
        direct: AllValidations.isPisPasep,
        zod: _validatePis,
      ),
      'Título de Eleitor': (
        valid: '006000610949',
        direct: AllValidations.isTituloEleitor,
        zod: _validateTitulo,
      ),
    };

    for (final entry in documents.entries) {
      test('${entry.key} aceita vetor válido independente', () {
        expect(entry.value.direct(entry.value.valid), isTrue);
        expect(entry.value.zod(entry.value.valid), isNull);
      });

      test('${entry.key} rejeita prefixo e sufixo arbitrários', () {
        final contaminated = 'abc${entry.value.valid}xyz';
        // A limpeza de não dígitos escondia o conteúdo externo.
        expect(entry.value.direct(contaminated), isFalse);
        expect(entry.value.zod(contaminated), isNotNull);
      });

      test('${entry.key} rejeita separador interno arbitrário', () {
        final value = entry.value.valid;
        final contaminated = '${value.substring(0, 1)}_${value.substring(1)}';
        expect(entry.value.direct(contaminated), isFalse);
        expect(entry.value.zod(contaminated), isNotNull);
      });
    }
  });

  group('Datas estritas', () {
    group('AllValidations.isDateTime', () {
      const validValues = [
        '2026-08-01T12:30:45.123Z',
        '2026-08-01 12:30:45.123',
      ];

      const invalidValues = [
        '2026-99-99T99:99:99.999Z',
        '2026-02-30T12:00:00.000Z',
        '2026-08-01T25:00:00.000Z',
        '2026-08-01T12:60:00.000Z',
        '2026-08-01T12:00:60.000Z',
        '2026-08-01T12:30:45X123Z',
        'prefixo2026-08-01T12:30:45.123Z',
      ];

      for (final value in validValues) {
        test('aceita DateTime real e integral: $value', () {
          expect(AllValidations.isDateTime(value), isTrue);
        });
      }

      for (final value in invalidValues) {
        test('rejeita DateTime impossível ou malformado: $value', () {
          expect(AllValidations.isDateTime(value), isFalse);
        });
      }
    });

    group('BrZod rejeita normalização de datas inválidas', () {
      test('rejeita dia excedente em yyyy-MM-dd', () {
        expect(BrZod().required().isDate().build('2020-01-42'), isNotNull);
      });

      test('rejeita 29 de fevereiro em ano não bissexto', () {
        expect(BrZod().required().isDate().build('2026-02-29'), isNotNull);
      });

      test('aceita 29 de fevereiro em ano bissexto', () {
        expect(BrZod().required().isDate().build('2024-02-29'), isNull);
      });

      test('rejeita mês 13', () {
        expect(BrZod().required().isDate().build('2026-13-01'), isNotNull);
      });

      test('rejeita data ISO com horário impossível', () {
        expect(
          BrZod().required().isDate().build('2026-08-01T25:00:00'),
          isNotNull,
        );
      });

      test('parsing estrito é compartilhado por isDate/isBefore/isAfter', () {
        const invalid = '2020-01-42';

        expect(g.isDate(invalid), isFalse);
        expect(g.isBeforeDate(invalid, DateTime(2020, 3)), isFalse);
        expect(g.isAfterDate(invalid, DateTime(2020)), isFalse);
        expect(
          BrZod().required().isBefore(DateTime(2020, 3)).build(invalid),
          isNotNull,
        );
        expect(
          BrZod().required().isAfter(DateTime(2020)).build(invalid),
          isNotNull,
        );
      });
    });
  });

  group('Consistência das APIs', () {
    test('CPF usa vetor independente antes da comparação entre APIs', () {
      const value = '529.982.247-25';
      final direct = AllValidations.isCpf(value);

      expect(direct, isTrue);
      expect(Contract().isValidCPF(value, 'cpf', 'inválido').isValid, direct);
      expect(BrZod().required().cpf().build(value) == null, direct);
    });

    test('CNPJ usa vetor independente antes da comparação entre APIs', () {
      const value = '11.222.333/0001-81';
      final direct = AllValidations.isCnpj(value);

      expect(direct, isTrue);
      expect(Contract().isValidCNPJ(value, 'cnpj', 'inválido').isValid, direct);
      expect(BrZod().required().cnpj().build(value) == null, direct);
    });

    test('documentos rejeitam lixo de forma consistente', () {
      const cases = [
        ('abc84718735264xyz', AllValidations.isCnh, _validateCnh),
        ('abc95606520941xyz', AllValidations.isRenavam, _validateRenavam),
        ('abc12345678919xyz', AllValidations.isPisPasep, _validatePis),
        ('abc006000610949xyz', AllValidations.isTituloEleitor, _validateTitulo),
      ];

      for (final (value, directValidator, zodValidator) in cases) {
        final direct = directValidator(value);
        expect(direct, isFalse, reason: 'vetor negativo independente: $value');
        expect(zodValidator(value) == null, direct, reason: value);
      }
    });
  });

  group('Exemplos documentados de CNPJ alfanumérico', () {
    const documentedExamples = [
      '12ABC34501DE35',
      '12.ABC.345/01DE-35',
    ];

    for (final value in documentedExamples) {
      test('exemplo documentado é válido: $value', () {
        expect(CnpjAlfanumerico.isValid(value), isTrue);
        expect(AllValidations.isCnpjAlphanumeric(value), isTrue);
        expect(BrZod().required().cnpjAlfa().build(value), isNull);
      });
    }

    test('exemplo gerado é validado pela própria biblioteca', () {
      final generated = CnpjAlfanumerico.generate(forceAlphanumeric: true);
      expect(CnpjAlfanumerico.isValid(generated), isTrue);
    });

    test('todo literal de CNPJ exibido no guia é realmente válido', () {
      final guide = File('doc/CnpjAlfanumerico.md').readAsStringSync();
      final raw = RegExp(r"'([A-Za-z0-9]{14})'")
          .allMatches(guide)
          .map((match) => match.group(1)!);
      final formatted = RegExp(
        r"'([A-Za-z0-9]{2}\.[A-Za-z0-9]{3}\.[A-Za-z0-9]{3}/[A-Za-z0-9]{4}-\d{2})'",
      ).allMatches(guide).map((match) => match.group(1)!);
      final literals = {...raw, ...formatted};

      expect(literals, isNotEmpty);
      for (final value in literals) {
        expect(
          CnpjAlfanumerico.isValid(value),
          isTrue,
          reason: 'O exemplo documentado "$value" precisa ter DVs válidos.',
        );
      }
    });
  });
}

String? _validateCnh(String value) => BrZod().required().cnh().build(value);

String? _validateRenavam(String value) =>
    BrZod().required().renavam().build(value);

String? _validatePis(String value) =>
    BrZod().required().pisPasep().build(value);

String? _validateTitulo(String value) =>
    BrZod().required().tituloEleitor().build(value);
