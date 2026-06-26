import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helper ────────────────────────────────────────────────────────────────────

String _apply(String text) {
  const mask = CurrencyMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  group('CurrencyMask — progressão de dígitos', () {
    test('vazio → vazio', () => expect(_apply(''), ''));

    test('1 dígito → centavos', () {
      expect(_apply('1'), 'R\$ 0,01');
    });

    test('2 dígitos → centavos completos', () {
      expect(_apply('12'), 'R\$ 0,12');
    });

    test('3 dígitos → 1 real', () {
      expect(_apply('123'), 'R\$ 1,23');
    });

    test('4 dígitos → 2 algarismos inteiros', () {
      expect(_apply('1234'), 'R\$ 12,34');
    });

    test('5 dígitos → 3 algarismos inteiros', () {
      expect(_apply('12345'), 'R\$ 123,45');
    });

    test('6 dígitos → milhar com ponto', () {
      expect(_apply('123456'), 'R\$ 1.234,56');
    });

    test('7 dígitos', () {
      expect(_apply('1234567'), 'R\$ 12.345,67');
    });

    test('8 dígitos', () {
      expect(_apply('12345678'), 'R\$ 123.456,78');
    });

    test('9 dígitos — dois pontos de milhar', () {
      expect(_apply('123456789'), 'R\$ 1.234.567,89');
    });
  });

  group('CurrencyMask — filtragem e re-aplicação', () {
    test('letras são ignoradas', () {
      expect(_apply('abc'), '');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_apply('1a2b3'), 'R\$ 1,23');
    });

    test('entrada já formatada é re-aplicada corretamente', () {
      expect(_apply('R\$ 1.234,56'), 'R\$ 1.234,56');
    });

    test('paste de valor com símbolo e máscara', () {
      expect(_apply('R\$ 12.345,67'), 'R\$ 12.345,67');
    });
  });

  group('CurrencyMask — zeros e casos especiais', () {
    test('somente zeros', () {
      expect(_apply('000'), 'R\$ 0,00');
    });

    test('valor com zeros à esquerda da parte inteira', () {
      expect(_apply('0012345'), 'R\$ 123,45');
    });

    test('valor exato de centavos (0,01)', () {
      expect(_apply('001'), 'R\$ 0,01');
    });

    test('valor exato de zero vírgula (0,10)', () {
      expect(_apply('010'), 'R\$ 0,10');
    });
  });

  group('CurrencyMask — truncamento (max 13 dígitos)', () {
    test('14 dígitos → descarta o mais antigo (mantém os 13 últimos)', () {
      // '12345678901234' → últimos 13 = '2345678901234'
      // int='23456789012', dec='34' → R$ 23.456.789.012,34
      expect(_apply('12345678901234'), 'R\$ 23.456.789.012,34');
    });
  });

  group('CurrencyMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = CurrencyMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '123456'),
      );
      const formatted = 'R\$ 1.234,56';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  group('CurrencyMask — compatibilidade com BrFormatter.parseCurrency', () {
    test('valor mascarado é parseável por BrFormatter', () {
      final masked = _apply('123456');
      expect(masked, 'R\$ 1.234,56');
      expect(BrFormatter.parseCurrency(masked), 1234.56);
    });

    test('round-trip: dígitos → mask → parseCurrency', () {
      final masked = _apply('8543710704');
      expect(masked, 'R\$ 85.437.107,04');
      expect(BrFormatter.parseCurrency(masked), 85437107.04);
    });
  });
}
