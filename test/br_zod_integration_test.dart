/// Testes de integração do módulo BrZod.
///
/// Valida o fluxo completo: BrZod.validate() com Map, aninhamento,
/// BrZodResult e consistência entre errors e errorList.
library;

import 'package:all_validations_br/br_zod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── BrZod.validate() — caso simples ──────────────────────────
  group('BrZod.validate() — flat', () {
    final params = {
      'email': BrZod().required().email(),
      'cpf': BrZod().required().cpf(),
      'cep': BrZod().optional().cep(),
    };

    test('todos válidos — isValid true', () {
      final result = BrZod.validate(
        data: {
          'email': 'user@example.com',
          'cpf': '529.982.247-25',
          'cep': '01310-100',
        },
        params: params,
      );
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
      expect(result.errors, isEmpty);
      expect(result.errorList, isEmpty);
    });

    test('email inválido — isNotValid', () {
      final result = BrZod.validate(
        data: {'email': 'nao-e-email', 'cpf': '529.982.247-25'},
        params: params,
      );
      expect(result.isNotValid, isTrue);
      expect(result.errors.containsKey('email'), isTrue);
      expect(result.errors.containsKey('cpf'), isFalse);
    });

    test('cpf inválido — erro apenas em cpf', () {
      final result = BrZod.validate(
        data: {'email': 'user@example.com', 'cpf': '111.111.111-11'},
        params: params,
      );
      expect(result.isNotValid, isTrue);
      expect(result.errors.containsKey('cpf'), isTrue);
      expect(result.errors.containsKey('email'), isFalse);
    });

    test('campo opcional ausente — sem erro', () {
      final result = BrZod.validate(
        data: {'email': 'user@example.com', 'cpf': '529.982.247-25'},
        params: params,
      );
      expect(result.isValid, isTrue);
    });

    test('campo opcional com valor inválido — erro', () {
      final result = BrZod.validate(
        data: {
          'email': 'user@example.com',
          'cpf': '529.982.247-25',
          'cep': '12345', // inválido
        },
        params: params,
      );
      expect(result.isNotValid, isTrue);
      expect(result.errors.containsKey('cep'), isTrue);
    });

    test('múltiplos erros — errors e errorList coerentes', () {
      final result = BrZod.validate(
        data: {'email': 'invalido', 'cpf': '000'},
        params: params,
      );
      expect(result.errors.length, equals(2));
      expect(result.errorList.length, equals(2));
      // errorList deve conter "email: ..." e "cpf: ..."
      expect(result.errorList.any((e) => e.startsWith('email:')), isTrue);
      expect(result.errorList.any((e) => e.startsWith('cpf:')), isTrue);
    });

    test('campo obrigatório vazio — erro', () {
      final result = BrZod.validate(
        data: {'email': '', 'cpf': ''},
        params: params,
      );
      expect(result.isNotValid, isTrue);
      expect(result.errors.containsKey('email'), isTrue);
      expect(result.errors.containsKey('cpf'), isTrue);
    });
  });

  // ── BrZod.validate() — aninhado ──────────────────────────────
  group('BrZod.validate() — nested Map', () {
    final params = {
      'user': {
        'email': BrZod().required().email(),
        'cpf': BrZod().required().cpf(),
      },
      'address': {
        'cep': BrZod().required().cep(),
      },
    };

    test('todos válidos', () {
      final result = BrZod.validate(
        data: {
          'user': {
            'email': 'user@example.com',
            'cpf': '529.982.247-25',
          },
          'address': {'cep': '01310-100'},
        },
        params: params,
      );
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('email aninhado inválido — errors[user][email]', () {
      final result = BrZod.validate(
        data: {
          'user': {'email': 'ruim', 'cpf': '529.982.247-25'},
          'address': {'cep': '01310-100'},
        },
        params: params,
      );
      expect(result.isNotValid, isTrue);
      final userErrors = result.errors['user'] as Map<String, dynamic>;
      expect(userErrors.containsKey('email'), isTrue);
    });

    test('errorList usa notação de ponto — user.email', () {
      final result = BrZod.validate(
        data: {
          'user': {'email': 'ruim', 'cpf': '529.982.247-25'},
          'address': {'cep': '01310-100'},
        },
        params: params,
      );
      expect(result.errorList.any((e) => e.startsWith('user.email:')), isTrue);
    });

    test('múltiplos níveis com erros em galhos distintos', () {
      final result = BrZod.validate(
        data: {
          'user': {'email': 'ruim', 'cpf': '000'},
          'address': {'cep': 'invalido'},
        },
        params: params,
      );
      expect(result.errors.containsKey('user'), isTrue);
      expect(result.errors.containsKey('address'), isTrue);
      expect(result.errorList.length, equals(3));
    });

    test('submap ausente — trata como vazio, reporta obrigatórios', () {
      final result = BrZod.validate(
        data: {'user': null, 'address': null},
        params: params,
      );
      expect(result.isNotValid, isTrue);
    });
  });

  // ── BrZodResult ───────────────────────────────────────────────
  group('BrZodResult', () {
    test('construtor direto — isValid', () {
      const r = BrZodResult(isValid: true, errors: {}, errorList: []);
      expect(r.isValid, isTrue);
      expect(r.isNotValid, isFalse);
    });

    test('construtor direto — isNotValid', () {
      const r = BrZodResult(
        isValid: false,
        errors: {'field': 'erro'},
        errorList: ['field: erro'],
      );
      expect(r.isNotValid, isTrue);
      expect(r.errors['field'], equals('erro'));
      expect(r.errorList.first, equals('field: erro'));
    });
  });

  // ── Importação via barrel lib/br_zod.dart ────────────────────
  group('Barrel lib/br_zod.dart exporta corretamente', () {
    test('BrZod instanciável', () => expect(BrZod(), isNotNull));
    test('BrZodResult instanciável', () {
      const r = BrZodResult(isValid: true, errors: {}, errorList: []);
      expect(r, isNotNull);
    });
    test('PasswordPolicy acessível', () {
      expect(PasswordPolicy.strong, isNotNull);
      expect(PasswordPolicy.medium, isNotNull);
      expect(PasswordPolicy.weak, isNotNull);
    });
    test(
        'LocalePtBR instanciável', () => expect(const LocalePtBR(), isNotNull));
  });
}
