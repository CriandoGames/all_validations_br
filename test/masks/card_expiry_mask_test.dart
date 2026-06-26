import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

String _apply(String text) {
  const mask = CardExpiryMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

void main() {
  // ── Formato MM/AA (≤ 4 dígitos) ──────────────────────────────────────────

  group('CardExpiryMask — MM/AA (≤ 4 dígitos)', () {
    test('vazio → vazio', () => expect(_apply(''), ''));
    test('1 dígito', () => expect(_apply('1'), '1'));
    test('2 dígitos — mês completo', () => expect(_apply('12'), '12'));
    test('3 dígitos — insere barra', () => expect(_apply('122'), '12/2'));
    test('4 dígitos — MM/AA completo', () => expect(_apply('1224'), '12/24'));
    test('mês 01', () => expect(_apply('0128'), '01/28'));
    test('mês 12', () => expect(_apply('1299'), '12/99'));
  });

  // ── Formato MM/AAAA (> 4 dígitos) ────────────────────────────────────────

  group('CardExpiryMask — MM/AAAA (> 4 dígitos)', () {
    test('5 dígitos — transitional', () => expect(_apply('12240'), '12/240'));
    test('6 dígitos — MM/AAAA completo', () {
      expect(_apply('122024'), '12/2024');
    });
    test('mês 01 + ano completo', () => expect(_apply('012027'), '01/2027'));
    test('mais de 6 dígitos são ignorados', () {
      expect(_apply('1220249'), '12/2024');
    });
    test('muito mais dígitos', () {
      expect(_apply('12202499999'), '12/2024');
    });
  });

  // ── Re-aplicação de entrada já mascarada ──────────────────────────────────

  group('CardExpiryMask — re-aplicação', () {
    test('MM/AA já mascarado', () => expect(_apply('12/24'), '12/24'));
    test('MM/AAAA já mascarado', () => expect(_apply('12/2024'), '12/2024'));
  });

  // ── Filtragem ─────────────────────────────────────────────────────────────

  group('CardExpiryMask — filtragem', () {
    test('letras são ignoradas', () => expect(_apply('abc'), ''));
    test('mistura letras e dígitos', () => expect(_apply('1a2b'), '12'));
  });

  // ── Cursor colapsado no final ─────────────────────────────────────────────

  group('CardExpiryMask — cursor colapsado no final', () {
    test('MM/AA — cursor ao final', () {
      const mask = CardExpiryMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1224'),
      );
      const formatted = '12/24';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });

    test('MM/AAAA — cursor ao final', () {
      const mask = CardExpiryMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '122024'),
      );
      const formatted = '12/2024';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
