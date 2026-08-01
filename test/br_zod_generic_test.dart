import 'package:all_validations_br/src/br_zod/validations/generic.dart' as g;
import 'package:all_validations_br/src/br_zod/br_zod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── isRequired ─────────────────────────────────────────────
  group('isRequired', () {
    test('rejeita null', () => expect(g.isRequired(null), isFalse));
    test('rejeita string vazia', () => expect(g.isRequired(''), isFalse));
    test('rejeita string só espaços', () => expect(g.isRequired('   '), isFalse));
    test('aceita string com conteúdo', () => expect(g.isRequired('abc'), isTrue));
    test('aceita número', () => expect(g.isRequired(0), isTrue));
  });

  // ── isEmpty ────────────────────────────────────────────────
  group('isEmpty', () {
    test('null é vazio', () => expect(g.isEmpty(null), isTrue));
    test('string vazia é vazio', () => expect(g.isEmpty(''), isTrue));
    test('espaços são vazio', () => expect(g.isEmpty('  '), isTrue));
    test('conteúdo não é vazio', () => expect(g.isEmpty('x'), isFalse));
  });

  // ── min / max ──────────────────────────────────────────────
  group('hasMinLength', () {
    test('3 chars >= 3', () => expect(g.hasMinLength('abc', 3), isTrue));
    test('2 chars < 3', () => expect(g.hasMinLength('ab', 3), isFalse));
    test('converte número para string', () => expect(g.hasMinLength(12345, 4), isTrue));
  });

  group('hasMaxLength', () {
    test('3 chars <= 5', () => expect(g.hasMaxLength('abc', 5), isTrue));
    test('6 chars > 5', () => expect(g.hasMaxLength('abcdef', 5), isFalse));
  });

  // ── email ──────────────────────────────────────────────────
  group('isEmail', () {
    test('válido', () => expect(g.isEmail('user@example.com'), isTrue));
    test('subdomínio', () => expect(g.isEmail('a@b.co.uk'), isTrue));
    test('sem @', () => expect(g.isEmail('userexample.com'), isFalse));
    test('sem domínio', () => expect(g.isEmail('user@'), isFalse));
    test('null retorna false', () => expect(g.isEmail(null), isFalse));
  });

  // ── phone ──────────────────────────────────────────────────
  group('isPhone', () {
    test('celular com DDD (11 dígitos)', () => expect(g.isPhone('11987654321'), isTrue));
    test('fixo com DDD (10 dígitos)', () => expect(g.isPhone('1133334444'), isTrue));
    test('celular formatado', () => expect(g.isPhone('(11) 98765-4321'), isTrue));
    test('fixo formatado', () => expect(g.isPhone('(11) 3333-4444'), isTrue));
    test('só 5 dígitos é inválido', () => expect(g.isPhone('12345'), isFalse));
    test('null retorna false', () => expect(g.isPhone(null), isFalse));
  });

  // ── equals ─────────────────────────────────────────────────
  group('isEquals', () {
    test('strings iguais', () => expect(g.isEquals('abc', 'abc'), isTrue));
    test('strings diferentes', () => expect(g.isEquals('abc', 'xyz'), isFalse));
    test('número vs string do mesmo valor', () => expect(g.isEquals(42, '42'), isTrue));
  });

  // ── type<T> ────────────────────────────────────────────────
  group('isType', () {
    test('String', () => expect(g.isType<String>('hello'), isTrue));
    test('não String', () => expect(g.isType<String>(42), isFalse));
    test('int literal', () => expect(g.isType<int>(10), isTrue));
    test('int parseable string', () => expect(g.isType<int>('10'), isTrue));
    test('int string inválida', () => expect(g.isType<int>('abc'), isFalse));
    test('double literal', () => expect(g.isType<double>(3.14), isTrue));
    test('bool literal', () => expect(g.isType<bool>(true), isTrue));
    test('bool string "true"', () => expect(g.isType<bool>('true'), isTrue));
    test('bool string inválida', () => expect(g.isType<bool>('maybe'), isFalse));
  });

  // ── isDate ─────────────────────────────────────────────────
  group('isDate', () {
    test('dd/MM/yyyy válido', () => expect(g.isDate('28/06/2026'), isTrue));
    test('yyyy-MM-dd válido', () => expect(g.isDate('2026-06-28'), isTrue));
    test('ISO 8601 válido', () => expect(g.isDate('2026-06-28T12:00:00'), isTrue));
    test('data inexistente 30/02', () => expect(g.isDate('30/02/2026'), isFalse));
    test('formato inválido', () => expect(g.isDate('28-06-2026'), isFalse));
    test('string vazia', () => expect(g.isDate(''), isFalse));
    test('null', () => expect(g.isDate(null), isFalse));
    // Ano bissexto
    test('29/02/2024 (bissexto)', () => expect(g.isDate('29/02/2024'), isTrue));
    test('29/02/2023 (não bissexto)', () => expect(g.isDate('29/02/2023'), isFalse));
  });

  // ── isBefore / isAfter ─────────────────────────────────────
  group('isBeforeDate / isAfterDate', () {
    final ref = DateTime(2026, 6, 28);
    test('antes da data max', () => expect(g.isBeforeDate('27/06/2026', ref), isTrue));
    test('depois da data max', () => expect(g.isBeforeDate('29/06/2026', ref), isFalse));
    test('depois da data min', () => expect(g.isAfterDate('29/06/2026', ref), isTrue));
    test('antes da data min', () => expect(g.isAfterDate('27/06/2026', ref), isFalse));
  });

  // ── BrZod fluente ──────────────────────────────────────────
  group('BrZod — encadeamento fluente', () {
    test('required — vazio retorna erro', () {
      final v = BrZod().required().build;
      expect(v(''), isNotNull);
      expect(v(null), isNotNull);
    });

    test('required — preenchido retorna null', () {
      final v = BrZod().required().build;
      expect(v('carlos'), isNull);
    });

    test('optional — vazio curto-circuita sem erro', () {
      final v = BrZod().optional().email().build;
      expect(v(''), isNull);   // vazio → ok
      expect(v(null), isNull); // null  → ok
    });

    test('optional — preenchido com email inválido retorna erro', () {
      final v = BrZod().optional().email().build;
      expect(v('nao-é-email'), isNotNull);
    });

    test('optional — preenchido com email válido retorna null', () {
      final v = BrZod().optional().email().build;
      expect(v('ok@email.com'), isNull);
    });

    test('min + max — cadeia completa', () {
      final v = BrZod().required().min(3).max(10).build;
      expect(v('ab'), isNotNull);          // muito curto
      expect(v('abcdefghijk'), isNotNull); // muito longo
      expect(v('abc'), isNull);            // ok
      expect(v('abcdefghij'), isNull);     // ok (10)
    });

    test('email válido retorna null', () {
      expect(BrZod().required().email().build('test@test.com'), isNull);
    });

    test('email inválido retorna mensagem', () {
      expect(BrZod().required().email().build('nao-email'), isNotNull);
    });

    test('equals — valores iguais', () {
      final v = BrZod().equals('senha123').build;
      expect(v('senha123'), isNull);
      expect(v('outra'), isNotNull);
    });

    test('custom — função arbitrária', () {
      final v = BrZod().custom((val) => val != 'admin', message: 'Reservado').build;
      expect(v('carlos'), isNull);
      expect(v('admin'), 'Reservado');
    });

    test('isDate — valida data no formato BR', () {
      expect(BrZod().required().isDate().build('28/06/2026'), isNull);
      expect(BrZod().required().isDate().build('99/99/9999'), isNotNull);
    });

    test('isBefore — data deve ser anterior', () {
      final v = BrZod().required().isBefore(DateTime(2026, 12, 31)).build;
      expect(v('28/06/2026'), isNull);
      expect(v('01/01/2027'), isNotNull);
    });

    test('isAfter — data deve ser posterior', () {
      final v = BrZod().required().isAfter(DateTime(2026, 1, 1)).build;
      expect(v('28/06/2026'), isNull);
      expect(v('01/01/2025'), isNotNull);
    });

    test('type<int> — valor inteiro', () {
      expect(BrZod().required().type<int>().build('42'), isNull);
      expect(BrZod().required().type<int>().build('abc'), isNotNull);
    });

    test('mensagem customizada sobrescreve locale', () {
      final v = BrZod().required('Preencha este campo').build;
      expect(v(''), equals('Preencha este campo'));
    });

    test('locale customizado', () {
      BrZod.defaultLocale = _TestLocale();
      final v = BrZod().required().build;
      expect(v(''), equals('OBRIGATORIO'));
      BrZod.defaultLocale = const LocalePtBR(); // restaura
    });
  });
}

// ── Locale de teste ────────────────────────────────────────
class _TestLocale implements ILocaleBrZod {
  @override String get required => 'OBRIGATORIO';
  @override String get email => 'EMAIL';
  @override String get phone => 'PHONE';
  @override String get equals => 'EQUALS';
  @override String get custom => 'CUSTOM';
  @override String get optional => 'OPTIONAL';
  @override String get invalidDate => 'DATE';
  @override String get invalidType => 'TYPE';
  @override String get password => 'PASSWORD';
  @override String get uuid => 'UUID';
  @override String get url => 'URL';
  @override String get ipv4 => 'IPV4';
  @override String get ipv6 => 'IPV6';
  @override String get regex => 'REGEX';
  @override String get cpf => 'CPF';
  @override String get cnpj => 'CNPJ';
  @override String get cnpjAlfa => 'CNPJ_ALFA';
  @override String get cpfCnpj => 'CPF_CNPJ';
  @override String get cep => 'CEP';
  @override String get rg => 'RG';
  @override String get placa => 'PLACA';
  @override String get cnh => 'CNH';
  @override String get renavam => 'RENAVAM';
  @override String get pisPasep => 'PIS';
  @override String get tituloEleitor => 'TITULO';
  @override String get cns => 'CNS';
  @override String min(int n) => 'MIN_$n';
  @override String max(int n) => 'MAX_$n';
  @override String minDate(DateTime d) => 'MIN_DATE';
  @override String maxDate(DateTime d) => 'MAX_DATE';
}
