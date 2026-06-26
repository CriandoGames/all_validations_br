import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _applyPhone(String text) {
  const mask = PhoneMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

String _applyCep(String text) {
  const mask = CepMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── PhoneMask ─────────────────────────────────────────────────────────────────

void main() {
  group('PhoneMask — progressão DDD', () {
    test('vazio → vazio', () => expect(_applyPhone(''), ''));

    test('1 dígito — abre parêntese', () {
      expect(_applyPhone('1'), '(1');
    });

    test('2 dígitos — DDD completo sem fechar', () {
      expect(_applyPhone('11'), '(11');
    });

    test('3 dígitos — insere ") "', () {
      expect(_applyPhone('113'), '(11) 3');
    });

    test('4 dígitos', () => expect(_applyPhone('1133'), '(11) 33'));
  });

  group('PhoneMask — formato fixo (10 dígitos)', () {
    test('6 dígitos', () => expect(_applyPhone('113333'), '(11) 3333'));

    test('7 dígitos — insere traço na posição 6', () {
      expect(_applyPhone('1133334'), '(11) 3333-4');
    });

    test('10 dígitos — fixo completo', () {
      expect(_applyPhone('1133334444'), '(11) 3333-4444');
    });
  });

  group('PhoneMask — formato celular (11 dígitos)', () {
    // Durante a digitação (<11 dígitos) o formato fixo (dashAt=6) é aplicado.
    // Ao atingir 11 dígitos o formatter reformata para o padrão celular.
    test('7 dígitos — traço já presente (formato fixo intermediário)', () {
      expect(_applyPhone('1199999'), '(11) 9999-9');
    });

    test('8 dígitos — formato fixo intermediário', () {
      expect(_applyPhone('11999998'), '(11) 9999-98');
    });

    test('11 dígitos — celular completo', () {
      expect(_applyPhone('11999998877'), '(11) 99999-8877');
    });

    test('transição 10→11 dígitos reforma máscara para celular', () {
      // Com 10 dígitos: (11) 9999-9999
      expect(_applyPhone('1199999999'), '(11) 9999-9999');
      // Com 11 dígitos: (11) 99999-9999 (11º dígito extra)
      expect(_applyPhone('11999999991'), '(11) 99999-9991');
    });
  });

  group('PhoneMask — truncamento', () {
    test('mais de 11 dígitos são ignorados', () {
      expect(_applyPhone('119999988771'), '(11) 99999-8877');
    });

    test('20 dígitos → apenas os 11 primeiros', () {
      expect(_applyPhone('11999998877123456789'), '(11) 99999-8877');
    });
  });

  group('PhoneMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyPhone('abc'), '');
    });

    test('entrada já mascarada (fixo) é re-aplicada', () {
      expect(_applyPhone('(11) 3333-4444'), '(11) 3333-4444');
    });

    test('entrada já mascarada (celular) é re-aplicada', () {
      expect(_applyPhone('(11) 99999-8877'), '(11) 99999-8877');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_applyPhone('11a3b3'), '(11) 33');
    });
  });

  group('PhoneMask — cursor colapsado no final', () {
    test('cursor ao final — fixo', () {
      const mask = PhoneMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1133334444'),
      );
      const formatted = '(11) 3333-4444';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });

    test('cursor ao final — celular', () {
      const mask = PhoneMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '11999998877'),
      );
      const formatted = '(11) 99999-8877';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  // ── CepMask ──────────────────────────────────────────────────────────────────

  group('CepMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyCep(''), ''));

    test('1 dígito', () => expect(_applyCep('0'), '0'));

    test('5 dígitos — sem traço ainda', () {
      expect(_applyCep('01310'), '01310');
    });

    test('6 dígitos — insere traço', () {
      expect(_applyCep('013101'), '01310-1');
    });

    test('7 dígitos', () => expect(_applyCep('0131010'), '01310-10'));

    test('8 dígitos — CEP completo', () {
      expect(_applyCep('01310100'), '01310-100');
    });
  });

  group('CepMask — truncamento', () {
    test('mais de 8 dígitos são ignorados', () {
      expect(_applyCep('013101009'), '01310-100');
    });
  });

  group('CepMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyCep('abc'), '');
    });

    test('entrada já mascarada é re-aplicada', () {
      expect(_applyCep('01310-100'), '01310-100');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_applyCep('0a1b3'), '013');
    });
  });

  group('CepMask — cursor colapsado no final', () {
    test('cursor ao final após formatação', () {
      const mask = CepMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '01310100'),
      );
      const formatted = '01310-100';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
