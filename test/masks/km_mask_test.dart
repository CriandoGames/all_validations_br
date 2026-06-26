import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

String _apply(String text) {
  const mask = KmMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

void main() {
  group('KmMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_apply(''), ''));
    test('1 dígito', () => expect(_apply('1'), '1'));
    test('3 dígitos — sem separador', () => expect(_apply('999'), '999'));
    test('4 dígitos — insere ponto', () => expect(_apply('1000'), '1.000'));
    test('5 dígitos', () => expect(_apply('12345'), '12.345'));
    test('6 dígitos', () => expect(_apply('999999'), '999.999'));
    test('7 dígitos — máximo', () => expect(_apply('9999999'), '9.999.999'));
  });

  group('KmMask — truncamento', () {
    test('mais de 7 dígitos são ignorados (pega os primeiros)', () {
      expect(_apply('99999999'), '9.999.999');
    });
    test('10 dígitos → apenas os 7 primeiros', () {
      expect(_apply('1234567890'), '1.234.567');
    });
  });

  group('KmMask — filtragem e normalização', () {
    test('letras são ignoradas', () => expect(_apply('abc'), ''));
    test('zeros à esquerda removidos', () => expect(_apply('00123'), '123'));
    test('entrada já mascarada é re-aplicada', () {
      expect(_apply('1.000'), '1.000');
    });
    test('entrada máxima já mascarada', () {
      expect(_apply('9.999.999'), '9.999.999');
    });
    test('espaços são removidos', () => expect(_apply('1 000'), '1.000'));
  });

  group('KmMask — cursor colapsado no final', () {
    test('cursor ao final após formatação', () {
      const mask = KmMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '999999'),
      );
      const formatted = '999.999';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
