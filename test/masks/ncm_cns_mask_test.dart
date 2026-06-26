import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

String _applyNcm(String text) {
  const mask = NcmMask();
  return mask
      .formatEditUpdate(const TextEditingValue(), TextEditingValue(text: text))
      .text;
}

String _applyCns(String text) {
  const mask = CnsMask();
  return mask
      .formatEditUpdate(const TextEditingValue(), TextEditingValue(text: text))
      .text;
}

void main() {
  // ── NcmMask ───────────────────────────────────────────────────────────────

  group('NcmMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyNcm(''), ''));
    test('1 dígito', () => expect(_applyNcm('1'), '1'));
    test('4 dígitos — sem ponto', () => expect(_applyNcm('1234'), '1234'));
    test('5 dígitos — insere primeiro ponto', () {
      expect(_applyNcm('12345'), '1234.5');
    });
    test('6 dígitos', () => expect(_applyNcm('123456'), '1234.56'));
    test('7 dígitos — insere segundo ponto', () {
      expect(_applyNcm('1234567'), '1234.56.7');
    });
    test('8 dígitos — NCM completo', () {
      expect(_applyNcm('12345678'), '1234.56.78');
    });
  });

  group('NcmMask — truncamento e filtragem', () {
    test('mais de 8 dígitos são ignorados', () {
      expect(_applyNcm('123456789'), '1234.56.78');
    });
    test('letras são ignoradas', () => expect(_applyNcm('abc'), ''));
    test('entrada já mascarada é re-aplicada', () {
      expect(_applyNcm('1234.56.78'), '1234.56.78');
    });
  });

  group('NcmMask — cursor colapsado no final', () {
    test('cursor ao final', () {
      const mask = NcmMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '12345678'),
      );
      const formatted = '1234.56.78';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  // ── CnsMask ───────────────────────────────────────────────────────────────

  group('CnsMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyCns(''), ''));
    test('1 dígito', () => expect(_applyCns('1'), '1'));
    test('3 dígitos — sem espaço', () => expect(_applyCns('111'), '111'));
    test('4 dígitos — insere primeiro espaço', () {
      expect(_applyCns('1112'), '111 2');
    });
    test('7 dígitos', () => expect(_applyCns('1112222'), '111 2222'));
    test('8 dígitos — insere segundo espaço', () {
      expect(_applyCns('11122223'), '111 2222 3');
    });
    test('11 dígitos', () {
      expect(_applyCns('11122223333'), '111 2222 3333');
    });
    test('12 dígitos — insere terceiro espaço', () {
      expect(_applyCns('111222233334'), '111 2222 3333 4');
    });
    test('15 dígitos — CNS completo', () {
      expect(_applyCns('111222233334444'), '111 2222 3333 4444');
    });
  });

  group('CnsMask — truncamento e filtragem', () {
    test('mais de 15 dígitos são ignorados', () {
      expect(_applyCns('1112222333344449'), '111 2222 3333 4444');
    });
    test('letras são ignoradas', () => expect(_applyCns('abc'), ''));
    test('entrada já mascarada é re-aplicada', () {
      expect(_applyCns('111 2222 3333 4444'), '111 2222 3333 4444');
    });
  });

  group('CnsMask — cursor colapsado no final', () {
    test('cursor ao final', () {
      const mask = CnsMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '111222233334444'),
      );
      const formatted = '111 2222 3333 4444';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
