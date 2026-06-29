import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── BoolExtension ─────────────────────────────────────────────────────────

  group('BoolExtension.isTrue', () {
    test('retorna true quando o valor é true', () {
      const bool valor = true;
      expect(valor.isTrue, isTrue);
    });

    test('retorna false quando o valor é false', () {
      const bool valor = false;
      expect(valor.isTrue, isFalse);
    });

    test('retorna false quando o valor é null', () {
      const bool? valor = null;
      expect(valor.isTrue, isFalse);
    });
  });

  group('BoolExtension.isFalse', () {
    test('retorna true quando o valor é false', () {
      const bool valor = false;
      expect(valor.isFalse, isTrue);
    });

    test('retorna false quando o valor é true', () {
      const bool valor = true;
      expect(valor.isFalse, isFalse);
    });

    test('retorna false quando o valor é null', () {
      const bool? valor = null;
      expect(valor.isFalse, isFalse);
    });
  });

  // ── StringExtension ───────────────────────────────────────────────────────

  group('StringExtension.isNullOrEmpty', () {
    test('retorna true quando null', () {
      const String? v = null;
      expect(v.isNullOrEmpty, isTrue);
    });

    test('retorna true quando vazia', () {
      expect(''.isNullOrEmpty, isTrue);
    });

    test('retorna false quando tem apenas espaços', () {
      expect('   '.isNullOrEmpty, isFalse);
    });

    test('retorna false quando tem conteúdo', () {
      expect('texto'.isNullOrEmpty, isFalse);
    });
  });

  group('StringExtension.isNotNullOrEmpty', () {
    test('retorna false quando null', () {
      const String? v = null;
      expect(v.isNotNullOrEmpty, isFalse);
    });

    test('retorna false quando vazia', () {
      expect(''.isNotNullOrEmpty, isFalse);
    });

    test('retorna true quando tem apenas espaços', () {
      expect('   '.isNotNullOrEmpty, isTrue);
    });

    test('retorna true quando tem conteúdo', () {
      expect('texto'.isNotNullOrEmpty, isTrue);
    });
  });

  group('StringExtension.isNullOrEmptyWithSpace', () {
    test('retorna true quando null', () {
      const String? v = null;
      expect(v.isNullOrEmptyWithSpace, isTrue);
    });

    test('retorna true quando vazia', () {
      expect(''.isNullOrEmptyWithSpace, isTrue);
    });

    test('retorna true quando tem apenas espaços', () {
      expect('   '.isNullOrEmptyWithSpace, isTrue);
    });

    test('retorna true quando tem tabs e quebras de linha', () {
      expect('\t\n'.isNullOrEmptyWithSpace, isTrue);
    });

    test('retorna false quando tem conteúdo real', () {
      expect('texto'.isNullOrEmptyWithSpace, isFalse);
    });

    test('retorna false quando tem conteúdo com espaços nas bordas', () {
      expect('  texto  '.isNullOrEmptyWithSpace, isFalse);
    });
  });

  group('StringExtension.isNotNullOrEmptyWithSpace', () {
    test('retorna false quando null', () {
      const String? v = null;
      expect(v.isNotNullOrEmptyWithSpace, isFalse);
    });

    test('retorna false quando vazia', () {
      expect(''.isNotNullOrEmptyWithSpace, isFalse);
    });

    test('retorna false quando tem apenas espaços', () {
      expect('   '.isNotNullOrEmptyWithSpace, isFalse);
    });

    test('retorna true quando tem conteúdo real', () {
      expect('texto'.isNotNullOrEmptyWithSpace, isTrue);
    });
  });

  group('StringExtension.truncate', () {
    test('retorna null quando a string é null', () {
      const String? v = null;
      expect(v.truncate(5), isNull);
    });

    test('retorna a string original quando menor que o limite', () {
      expect('Dart'.truncate(10), equals('Dart'));
    });

    test('retorna a string original quando igual ao limite', () {
      expect('Dart'.truncate(4), equals('Dart'));
    });

    test('trunca e adiciona ... quando maior que o limite', () {
      expect('Flutter'.truncate(4), equals('Flut...'));
    });

    test('trunca string longa corretamente', () {
      expect('texto longo demais'.truncate(5), equals('texto...'));
    });
  });

  // ── ListExtension ─────────────────────────────────────────────────────────

  group('ListExtension.isNullOrEmpty', () {
    test('retorna true quando null', () {
      List<String>? lista;
      expect(lista.isNullOrEmpty, isTrue);
    });

    test('retorna true quando vazia', () {
      expect(<int>[].isNullOrEmpty, isTrue);
    });

    test('retorna false quando tem elementos', () {
      expect([1, 2, 3].isNullOrEmpty, isFalse);
    });
  });

  group('ListExtension.isNotNullOrEmpty', () {
    test('retorna false quando null', () {
      List<String>? lista;
      expect(lista.isNotNullOrEmpty, isFalse);
    });

    test('retorna false quando vazia', () {
      expect(<int>[].isNotNullOrEmpty, isFalse);
    });

    test('retorna true quando tem elementos', () {
      expect([1, 2, 3].isNotNullOrEmpty, isTrue);
    });
  });
}
