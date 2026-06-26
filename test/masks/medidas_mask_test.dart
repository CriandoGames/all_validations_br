import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

String _applyAltura(String text) {
  const mask = AlturaMask();
  return mask
      .formatEditUpdate(const TextEditingValue(), TextEditingValue(text: text))
      .text;
}

String _applyPeso(String text) {
  const mask = PesoMask();
  return mask
      .formatEditUpdate(const TextEditingValue(), TextEditingValue(text: text))
      .text;
}

String _applyTemp(String text) {
  const mask = TemperaturaMask();
  return mask
      .formatEditUpdate(const TextEditingValue(), TextEditingValue(text: text))
      .text;
}

void main() {
  // ── AlturaMask ────────────────────────────────────────────────────────────

  group('AlturaMask — progressão', () {
    test('vazio → vazio', () => expect(_applyAltura(''), ''));
    test('1 dígito — sem vírgula', () => expect(_applyAltura('2'), '2'));
    test('2 dígitos — insere vírgula', () => expect(_applyAltura('17'), '1,7'));
    test('3 dígitos — X,XX', () => expect(_applyAltura('175'), '1,75'));
    test('mínimo: 0,50', () => expect(_applyAltura('050'), '0,50'));
    test('máximo: 2,99', () => expect(_applyAltura('299'), '2,99'));
  });

  group('AlturaMask — truncamento e filtragem', () {
    test('mais de 3 dígitos são ignorados', () {
      expect(_applyAltura('1234'), '1,23');
    });
    test('letras são ignoradas', () => expect(_applyAltura('abc'), ''));
    test('entrada já mascarada é re-aplicada', () {
      expect(_applyAltura('1,70'), '1,70');
    });
  });

  group('AlturaMask — cursor colapsado no final', () {
    test('cursor ao final', () {
      const mask = AlturaMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '175'),
      );
      const formatted = '1,75';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  // ── PesoMask ──────────────────────────────────────────────────────────────

  group('PesoMask — progressão', () {
    test('vazio → vazio', () => expect(_applyPeso(''), ''));
    test('1 dígito', () => expect(_applyPeso('7'), '7'));
    test('2 dígitos', () => expect(_applyPeso('70'), '70'));
    test('3 dígitos — sem vírgula', () => expect(_applyPeso('705'), '705'));
    test('4 dígitos — XXX,X', () => expect(_applyPeso('7051'), '705,1'));
    test('máximo: 999,9', () => expect(_applyPeso('9999'), '999,9'));
  });

  group('PesoMask — truncamento e filtragem', () {
    test('mais de 4 dígitos são ignorados', () {
      expect(_applyPeso('99999'), '999,9');
    });
    test('letras são ignoradas', () => expect(_applyPeso('abc'), ''));
    test('entrada já mascarada é re-aplicada', () {
      expect(_applyPeso('705,1'), '705,1');
    });
  });

  group('PesoMask — cursor colapsado no final', () {
    test('cursor ao final', () {
      const mask = PesoMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '7051'),
      );
      const formatted = '705,1';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  // ── TemperaturaMask ───────────────────────────────────────────────────────

  group('TemperaturaMask — progressão', () {
    test('vazio → vazio', () => expect(_applyTemp(''), ''));
    test('1 dígito', () => expect(_applyTemp('2'), '2'));
    test('2 dígitos — sem vírgula', () => expect(_applyTemp('27'), '27'));
    test('3 dígitos — XX,X', () => expect(_applyTemp('271'), '27,1'));
    test('temperatura corporal: 36,5', () => expect(_applyTemp('365'), '36,5'));
    test('mínimo: 00,0', () => expect(_applyTemp('000'), '00,0'));
    test('máximo: 99,9', () => expect(_applyTemp('999'), '99,9'));
  });

  group('TemperaturaMask — truncamento e filtragem', () {
    test('mais de 3 dígitos são ignorados', () {
      expect(_applyTemp('2719'), '27,1');
    });
    test('letras são ignoradas', () => expect(_applyTemp('abc'), ''));
    test('entrada já mascarada é re-aplicada', () {
      expect(_applyTemp('27,1'), '27,1');
    });
  });

  group('TemperaturaMask — cursor colapsado no final', () {
    test('cursor ao final', () {
      const mask = TemperaturaMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '365'),
      );
      const formatted = '36,5';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
