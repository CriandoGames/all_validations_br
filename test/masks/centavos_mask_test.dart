import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

String _apply(String text) {
  const mask = CentavosMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

void main() {
  group('CentavosMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_apply(''), ''));
    test('"0" → "0,00"', () => expect(_apply('0'), '0,00'));
    test('"1" → "0,01"', () => expect(_apply('1'), '0,01'));
    test('"12" → "0,12"', () => expect(_apply('12'), '0,12'));
    test('"123" → "1,23"', () => expect(_apply('123'), '1,23'));
    test('"1234" → "12,34"', () => expect(_apply('1234'), '12,34'));
    test('"7194" → "71,94"', () => expect(_apply('7194'), '71,94'));
    test('"100000" → "1.000,00"', () => expect(_apply('100000'), '1.000,00'));
    test('"1234567" → "12.345,67"', () {
      expect(_apply('1234567'), '12.345,67');
    });
    test('"85437107" → "854.371,07"', () {
      expect(_apply('85437107'), '854.371,07');
    });
  });

  group('CentavosMask — truncamento (últimos 13 dígitos)', () {
    test('13 dígitos — máximo', () {
      expect(_apply('1234567890123'), '12.345.678.901,23');
    });
    test('14 dígitos → descarta o mais antigo', () {
      expect(_apply('12345678901234'), '23.456.789.012,34');
    });
  });

  group('CentavosMask — filtragem', () {
    test('letras são ignoradas', () => expect(_apply('abc'), ''));
    test('mistura letras e dígitos', () => expect(_apply('1a2b3'), '1,23'));
  });

  group('CentavosMask — diferença em relação à CurrencyMask', () {
    test('sem prefixo R\$', () {
      const centavos = CentavosMask();
      const currency = CurrencyMask();
      const tv = TextEditingValue(text: '7194');
      final c = centavos.formatEditUpdate(const TextEditingValue(), tv).text;
      final r = currency.formatEditUpdate(const TextEditingValue(), tv).text;
      expect(c, '71,94');
      expect(r, 'R\$ 71,94');
      expect(c, isNot(contains('R\$')));
    });
  });

  group('CentavosMask — cursor colapsado no final', () {
    test('cursor ao final após formatação', () {
      const mask = CentavosMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1234567'),
      );
      const formatted = '12.345,67';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
