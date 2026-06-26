import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper: simula o usuário digitando [text] em um campo limpo.
String _apply(String text) {
  const mask = CpfMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

void main() {
  group('CpfMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_apply(''), ''));

    test('1 dígito', () => expect(_apply('1'), '1'));

    test('3 dígitos — sem ponto ainda', () => expect(_apply('123'), '123'));

    test('4 dígitos — insere primeiro ponto', () {
      expect(_apply('1234'), '123.4');
    });

    test('6 dígitos', () => expect(_apply('123456'), '123.456'));

    test('7 dígitos — insere segundo ponto', () {
      expect(_apply('1234567'), '123.456.7');
    });

    test('9 dígitos', () => expect(_apply('123456789'), '123.456.789'));

    test('10 dígitos — insere traço', () {
      expect(_apply('1234567890'), '123.456.789-0');
    });

    test('11 dígitos — CPF completo', () {
      expect(_apply('12345678901'), '123.456.789-01');
    });
  });

  group('CpfMask — truncamento', () {
    test('mais de 11 dígitos são ignorados', () {
      expect(_apply('123456789012'), '123.456.789-01');
    });

    test('entrada com 20 dígitos → apenas os 11 primeiros', () {
      expect(_apply('12345678901234567890'), '123.456.789-01');
    });
  });

  group('CpfMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_apply('abc'), '');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_apply('1a2b3c'), '123');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      // Simula paste de CPF formatado
      expect(_apply('123.456.789-01'), '123.456.789-01');
    });

    test('espaços e caracteres especiais são removidos', () {
      expect(_apply('123 456 789'), '123.456.789');
    });
  });

  group('CpfMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = CpfMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '12345678901'),
      );
      const formatted = '123.456.789-01';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  group('CpfMask — compatibilidade com AllValidations.isCpf', () {
    test('CPF mascarado é reconhecido como válido', () {
      // CPF válido conhecido: 529.982.247-25
      final masked = _apply('52998224725');
      expect(masked, '529.982.247-25');
      expect(AllValidations.isCpf(masked), isTrue);
    });
  });
}
