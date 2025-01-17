import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HelperUtil', () {
    test('decodeJWT', () {
      final jwt =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      final payload = HelperUtil.decodeJWT(jwt);
      expect(payload, isNotNull);
      expect(payload?['name'], 'John Doe');
    });

    test('getDeviceInfo', () {
      final info = HelperUtil.getDeviceInfo();
      expect(info['os'], isNotEmpty);
    });

    test('convertUtcToLocal', () {
      final utcDate = DateTime.utc(2023, 1, 1);
      final localDate = HelperUtil.convertUtcToLocal(utcDate);
      expect(localDate.isUtc, isFalse);
    });

    test('convertLocalToUtc', () {
      final localDate = DateTime.now();
      final utcDate = HelperUtil.convertLocalToUtc(localDate);
      expect(utcDate.isUtc, isTrue);
    });

    test('validatePixKey', () {
      expect(HelperUtil.validatePixKey('12345678909'), 'CPF');
      expect(HelperUtil.validatePixKey('+5511999999999'), 'Celular');
      expect(HelperUtil.validatePixKey('email@domain.com'), 'Email');
      expect(HelperUtil.validatePixKey('123e4567e89b12d3a456426614174000'),
          'Chave Aleatória');
      expect(HelperUtil.validatePixKey('invalid'), isNull);
    });

    test('formatText', () {
      expect(
          HelperUtil.formatText('11999999999', 'celular'), '(11) 99999-9999');
      expect(HelperUtil.formatText('2023-01-01', 'data'), '01/01/2023');
      expect(HelperUtil.formatText('1234.56', 'dinheiro'), 'R\$ 1234,56');
      expect(HelperUtil.formatText('12345678909', 'cpf'), '123.456.789-09');
      expect(HelperUtil.formatText('12345678000195', 'cnpj'),
          '12.345.678/0001-95');
      expect(HelperUtil.formatText(' EMAIL@DOMAIN.COM ', 'email'),
          'email@domain.com');
    });

    test('Gerar número aleatório', () {
      int random = HelperUtil.generateRandomInt(1, 10);
      expect(random, inInclusiveRange(1, 10));
    });

    test('Calcular porcentagem', () {
      double percentage = HelperUtil.calculatePercentage(50, 200);
      expect(percentage, 25.0);

      expect(() => HelperUtil.calculatePercentage(50, 0), throwsArgumentError);
    });

    test('Calcular idade', () {
      DateTime birthDate = DateTime(2000, 1, 1);
      int age = HelperUtil.calculateAge(birthDate);
      expect(age, greaterThanOrEqualTo(23));
    });

    test('Remover caracteres não numéricos', () {
      expect(HelperUtil.removeNonNumeric('ABC123!@#'), '123');
    });

    test('Formatar número para moeda brasileira', () {
      expect(HelperUtil.formatCurrency(1234.56), 'R\$ 1.234,56');
      expect(HelperUtil.formatCurrency(0.1), 'R\$ 0,10');
    });

    test('Calcular diferença em dias entre datas', () {
      DateTime start = DateTime(2023, 1, 1);
      DateTime end = DateTime(2023, 1, 10);
      int days = HelperUtil.daysBetween(start, end);
      expect(days, 9);
    });

    test('Gerar string aleatória', () {
      String randomString = HelperUtil.generateRandomString(10);
      expect(randomString.length, 10);
    });

    test('Capitalizar palavras', () {
      expect(HelperUtil.capitalizeWords('hello world'), 'Hello World');
    });

    test('Calcular dias úteis', () {
      DateTime start = DateTime(2023, 1, 1); // Domingo
      DateTime end = DateTime(2023, 1, 10); // Terça
      int businessDays = HelperUtil.businessDaysBetween(start, end);
      expect(businessDays, 7);
    });

    test('Verificar ano bissexto', () {
      expect(HelperUtil.isLeapYear(2020), true);
      expect(HelperUtil.isLeapYear(2023), false);
    });
  });

  group('PasswordUtils', () {
    const password = 'MinhaSenha123';
    const securityKey = 'ChaveSegura!@#';
    const salt = 'SaltUnico2025';

    test('EncryptPassword deve gerar um hash único', () {
      final encrypted = HelperUtil.encryptPassword(password, securityKey, salt);
      expect(encrypted, isNotNull);
      expect(encrypted.split(':').length, 2); // Deve ter salt e hash
    });

    test('ValidatePassword deve retornar true para senha válida', () {
      final encrypted = HelperUtil.encryptPassword(password, securityKey, salt);
      final isValid =
          HelperUtil.validatePassword(password, securityKey, encrypted);
      expect(isValid, isTrue);
    });

    test('ValidatePassword deve retornar false para senha incorreta', () {
      final encrypted = HelperUtil.encryptPassword(password, securityKey, salt);
      final isValid =
          HelperUtil.validatePassword('SenhaErrada', securityKey, encrypted);
      expect(isValid, isFalse);
    });

    test(
        'ValidatePassword deve retornar false para chave de segurança incorreta',
        () {
      final encrypted = HelperUtil.encryptPassword(password, securityKey, salt);
      final isValid =
          HelperUtil.validatePassword(password, 'ChaveErrada', encrypted);
      expect(isValid, isFalse);
    });

    test('EncryptPassword deve lançar erro para entradas inválidas', () {
      expect(() => HelperUtil.encryptPassword('', securityKey, salt),
          throwsArgumentError);
      expect(() => HelperUtil.encryptPassword(password, '', salt),
          throwsArgumentError);
      expect(() => HelperUtil.encryptPassword(password, securityKey, ''),
          throwsArgumentError);
    });

    test('ValidatePassword deve retornar false para hash inválido', () {
      final isValid =
          HelperUtil.validatePassword(password, securityKey, 'hash_invalido');
      expect(isValid, isFalse);
    });
  });

  group('HelperUtil.removeHtmlTags', () {
    test('Remove tags HTML simples', () {
      final input = "<p>Olá, mundo!</p>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("Olá, mundo!"));
    });

    test('Remove tags HTML aninhadas', () {
      final input =
          "<div><p>Texto com <strong>tags</strong> aninhadas.</p></div>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("Texto com tags aninhadas."));
    });

    test('Remove múltiplas tags HTML diferentes', () {
      final input =
          "<header>Header</header><main>Conteúdo</main><footer>Rodapé</footer>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("HeaderConteúdoRodapé"));
    });

    test('Remove tags HTML com atributos', () {
      final input = "<a href='https://example.com'>Link</a>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("Link"));
    });

    test('Texto sem tags HTML permanece inalterado', () {
      final input = "Texto simples sem HTML.";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("Texto simples sem HTML."));
    });

    test('Texto vazio retorna vazio', () {
      final input = "";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals(""));
    });

    test('Remove tags HTML não convencionais', () {
      final input = "<custom-tag>Custom Content</custom-tag>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("Custom Content"));
    });

    test('Remove tags HTML com maiúsculas', () {
      final input = "<DIV><P>Texto em maiúsculas</P></DIV>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals("Texto em maiúsculas"));
    });

    test('Remove tags HTML com conteúdo vazio', () {
      final input = "<p></p><div></div>";
      final result = HelperUtil.removeHtmlTags(input);
      expect(result, equals(""));
    });
  });
}
