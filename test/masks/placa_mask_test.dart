import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helper ────────────────────────────────────────────────────────────────────

String _apply(String text) {
  const mask = PlacaMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  group('PlacaMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_apply(''), ''));

    test('1 char', () => expect(_apply('A'), 'A'));

    test('3 chars — sem hífen ainda', () => expect(_apply('ABC'), 'ABC'));

    test('4 chars — insere hífen', () => expect(_apply('ABC1'), 'ABC-1'));

    test('7 chars — placa completa (formato antigo)', () {
      expect(_apply('ABC1234'), 'ABC-1234');
    });

    test('7 chars — placa completa (Mercosul)', () {
      expect(_apply('ABC1D23'), 'ABC-1D23');
    });
  });

  group('PlacaMask — conversão e filtragem', () {
    test('minúsculas convertidas para maiúsculas', () {
      expect(_apply('abc1234'), 'ABC-1234');
    });

    test('hífen do paste é removido antes de aplicar máscara', () {
      expect(_apply('abc-1234'), 'ABC-1234');
    });

    test('entrada já mascarada (antigo) é re-aplicada', () {
      expect(_apply('ABC-1234'), 'ABC-1234');
    });

    test('entrada já mascarada (Mercosul) é re-aplicada', () {
      expect(_apply('ABC-1D23'), 'ABC-1D23');
    });

    test('caracteres especiais são removidos', () {
      expect(_apply('A!B@C#1'), 'ABC-1');
    });

    test('espaços são removidos', () {
      expect(_apply('ABC 1234'), 'ABC-1234');
    });
  });

  group('PlacaMask — truncamento', () {
    test('mais de 7 chars são ignorados', () {
      expect(_apply('ABC12345678'), 'ABC-1234');
    });

    test('Mercosul com overflow', () {
      expect(_apply('ABC1D2399'), 'ABC-1D23');
    });
  });

  group('PlacaMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = PlacaMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: 'ABC1234'),
      );
      const formatted = 'ABC-1234';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });

    test('cursor ao final — Mercosul', () {
      const mask = PlacaMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: 'ABC1D23'),
      );
      const formatted = 'ABC-1D23';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
