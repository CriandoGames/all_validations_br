import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Contract.toResult ─────────────────────────────────────────────────────

  group('Contract.toResult', () {
    test('retorna Success quando o contrato é válido', () {
      final result = Contract()
          .requires()
          .isEmail('carlos@exemplo.com', 'email', 'Email inválido')
          .toResult('carlos@exemplo.com');

      expect(result.isSuccess, isTrue);
      expect(result.successValue, 'carlos@exemplo.com');
    });

    test('retorna Failure com todas as notificações', () {
      final result = Contract()
          .requires()
          .isEmail('invalido', 'email', 'Email inválido')
          .hasMinLen('a', 3, 'nome', 'Mínimo 3 caracteres')
          .toResult('qualquer coisa');

      expect(result.isFailure, isTrue);
      final errors = result.failureValue;
      expect(errors.length, 2);
      expect(errors[0].property, 'email');
      expect(errors[1].property, 'nome');
    });

    test('Failure retorna lista imutável', () {
      final result = Contract()
          .requires()
          .isEmail('x', 'email', 'E-mail inválido')
          .toResult('ok');

      expect(
          () => result.failureValue.add(
                ValidationNotification(property: 'x', message: 'x'),
              ),
          throwsUnsupportedError);
    });

    test('funciona com tipo genérico customizado', () {
      final dto = {'cpf': '529.982.247-25', 'email': 'a@b.com'};

      final result = Contract()
          .requires()
          .isValidCPF(dto['cpf']!, 'cpf', 'CPF inválido')
          .isEmail(dto['email']!, 'email', 'E-mail inválido')
          .toResult(dto);

      expect(result.isSuccess, isTrue);
      expect(result.successValue, dto);
    });
  });

  // ── Contract.toResultFirst ────────────────────────────────────────────────

  group('Contract.toResultFirst', () {
    test('retorna Success quando válido', () {
      final result = Contract()
          .requires()
          .isEmail('ok@ok.com', 'email', 'inválido')
          .toResultFirst('ok@ok.com');

      expect(result.isSuccess, isTrue);
    });

    test('retorna apenas o primeiro erro', () {
      final result = Contract()
          .requires()
          .isEmail('x', 'email', 'E-mail inválido')
          .hasMinLen('a', 5, 'nome', 'Nome curto')
          .toResultFirst('ok');

      expect(result.isFailure, isTrue);
      expect(result.failureValue.property, 'email');
      expect(result.failureValue.message, 'E-mail inválido');
    });
  });

  // ── Contract.toResultAsync ────────────────────────────────────────────────

  group('Contract.toResultAsync', () {
    test('executa valueFn e retorna Success quando válido', () async {
      final result = await Contract()
          .requires()
          .isEmail('ok@ok.com', 'email', 'inválido')
          .toResultAsync(() async => 'valor-async');

      expect(result.isSuccess, isTrue);
      expect(result.successValue, 'valor-async');
    });

    test('retorna Failure sem executar valueFn quando inválido', () async {
      int calls = 0;

      final result = await Contract()
          .requires()
          .isEmail('invalido', 'email', 'E-mail inválido')
          .toResultAsync(() async {
        calls++;
        return 'não deveria executar';
      });

      expect(result.isFailure, isTrue);
      expect(calls, 0);
    });
  });

  // ── ValidationNotifiable.toResult ────────────────────────────────────────

  group('ValidationNotifiable.toResult', () {
    test('retorna Success quando sem notificações', () {
      final notifiable = ValidationNotifiable();
      final result = notifiable.toResult(42);
      expect(result.isSuccess, isTrue);
      expect(result.successValue, 42);
    });

    test('retorna Failure quando há notificações', () {
      final notifiable = ValidationNotifiable();
      notifiable.addNotifications(
        ValidationNotification(property: 'campo', message: 'Erro'),
      );
      final result = notifiable.toResult(42);
      expect(result.isFailure, isTrue);
      expect(result.failureValue.first.property, 'campo');
    });
  });

  // ── validate*() nos validadores ──────────────────────────────────────────

  group('AllValidations.validateCPF', () {
    test('CPF válido retorna Success com dígitos normalizados', () {
      final r = AllValidations.validateCPF('529.982.247-25');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, '52998224725');
    });

    test('CPF inválido retorna Failure', () {
      final r = AllValidations.validateCPF('000.000.000-00');
      expect(r.isFailure, isTrue);
      expect(r.failureValue.property, 'cpf');
    });

    test('property e message customizáveis', () {
      final r = AllValidations.validateCPF(
        '000.000.000-00',
        property: 'documento',
        message: 'Documento inválido',
      );
      expect(r.failureValue.property, 'documento');
      expect(r.failureValue.message, 'Documento inválido');
    });
  });

  group('AllValidations.validateCNPJ', () {
    test('CNPJ válido retorna Success', () {
      final r = AllValidations.validateCNPJ('11.222.333/0001-81');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, '11222333000181');
    });

    test('CNPJ inválido retorna Failure', () {
      final r = AllValidations.validateCNPJ('00.000.000/0000-00');
      expect(r.isFailure, isTrue);
    });
  });

  group('AllValidations.validateEmail', () {
    test('e-mail válido retorna Success em lowercase', () {
      final r = AllValidations.validateEmail('Carlos@Exemplo.COM');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, 'carlos@exemplo.com');
    });

    test('e-mail inválido retorna Failure', () {
      final r = AllValidations.validateEmail('nao-e-email');
      expect(r.isFailure, isTrue);
    });
  });

  group('AllValidations.validateCEP', () {
    test('CEP válido retorna Success com dígitos', () {
      final r = AllValidations.validateCEP('01310-100');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, '01310100');
    });

    test('CEP inválido retorna Failure', () {
      final r = AllValidations.validateCEP('0000-00');
      expect(r.isFailure, isTrue);
    });
  });

  group('AllValidations.validateCellPhone', () {
    test('celular com DDD válido retorna Success', () {
      final r = AllValidations.validateCellPhone('(11) 91234-5678');
      expect(r.isSuccess, isTrue);
    });

    test('número inválido retorna Failure', () {
      final r = AllValidations.validateCellPhone('1234');
      expect(r.isFailure, isTrue);
    });
  });

  group('AllValidations.validatePixKey', () {
    test('CPF como chave PIX retorna Success com tipo', () {
      final r = AllValidations.validatePixKey('529.982.247-25');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, 'CPF');
    });

    test('celular como chave PIX retorna Success com tipo', () {
      final r = AllValidations.validatePixKey('+5511912345678');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, 'Celular');
    });

    test('e-mail como chave PIX retorna Success com tipo', () {
      final r = AllValidations.validatePixKey('carlos@exemplo.com');
      expect(r.isSuccess, isTrue);
      expect(r.successValue, 'Email');
    });

    test('chave inválida retorna Failure', () {
      final r = AllValidations.validatePixKey('invalido!!!');
      expect(r.isFailure, isTrue);
      expect(r.failureValue.property, 'chavePix');
    });
  });

  group('AllValidations.validateStrongPassword', () {
    test('senha forte retorna Success', () {
      final r = AllValidations.validateStrongPassword('Abc@12345');
      expect(r.isSuccess, isTrue);
    });

    test('senha fraca retorna Failure', () {
      final r = AllValidations.validateStrongPassword('fraca');
      expect(r.isFailure, isTrue);
    });
  });

  // ── ValidationResult typedef ──────────────────────────────────────────────

  group('ValidationResult typedef', () {
    test('é equivalente a Result<List<ValidationNotification>, T>', () {
      ValidationResult<String> r = Contract()
          .requires()
          .isEmail('ok@ok.com', 'email', 'inválido')
          .toResult('ok@ok.com');
      expect(r.isSuccess, isTrue);
    });
  });

  // ── Railway chain: validate + Contract ───────────────────────────────────

  group('Railway chain: validate → map → fold', () {
    test('chain completo com sucesso', () {
      final msg = AllValidations.validateCPF('529.982.247-25')
          .then((cpf) => AllValidations.validateEmail('carlos@exemplo.com'))
          .map((email) => 'CPF e email válidos para $email')
          .fold((err) => 'Erro: ${err.message}', (ok) => ok);

      expect(msg, contains('carlos@exemplo.com'));
    });

    test('chain interrompido em CPF inválido', () {
      int calls = 0;
      final msg = AllValidations.validateCPF('000.000.000-00').then((cpf) {
        calls++;
        return AllValidations.validateEmail('carlos@exemplo.com');
      }).fold((err) => 'Erro: ${err.message}', (ok) => ok);

      expect(msg, startsWith('Erro:'));
      expect(calls, 0);
    });
  });
}
