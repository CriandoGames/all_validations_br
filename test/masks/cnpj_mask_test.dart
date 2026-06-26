import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _applyNumeric(String text) {
  const mask = CnpjMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

String _applyAlfa(String text) {
  const mask = CnpjAlfaMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── CnpjMask (numérico) ───────────────────────────────────────────────────────

void main() {
  group('CnpjMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyNumeric(''), ''));

    test('1 dígito', () => expect(_applyNumeric('1'), '1'));

    test('2 dígitos — sem ponto ainda', () {
      expect(_applyNumeric('11'), '11');
    });

    test('3 dígitos — insere primeiro ponto', () {
      expect(_applyNumeric('112'), '11.2');
    });

    test('5 dígitos', () => expect(_applyNumeric('11222'), '11.222'));

    test('6 dígitos — insere segundo ponto', () {
      expect(_applyNumeric('112223'), '11.222.3');
    });

    test('8 dígitos', () => expect(_applyNumeric('11222333'), '11.222.333'));

    test('9 dígitos — insere barra', () {
      expect(_applyNumeric('112223330'), '11.222.333/0');
    });

    test('12 dígitos', () {
      expect(_applyNumeric('112223330001'), '11.222.333/0001');
    });

    test('13 dígitos — insere traço', () {
      expect(_applyNumeric('1122233300018'), '11.222.333/0001-8');
    });

    test('14 dígitos — CNPJ completo', () {
      expect(_applyNumeric('11222333000181'), '11.222.333/0001-81');
    });
  });

  group('CnpjMask — truncamento', () {
    test('mais de 14 dígitos são ignorados', () {
      expect(_applyNumeric('112223330001819'), '11.222.333/0001-81');
    });

    test('entrada com 20 dígitos → apenas os 14 primeiros', () {
      expect(_applyNumeric('11222333000181999'), '11.222.333/0001-81');
    });
  });

  group('CnpjMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyNumeric('abc'), '');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_applyNumeric('1a1b2'), '11.2');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      expect(_applyNumeric('11.222.333/0001-81'), '11.222.333/0001-81');
    });

    test('espaços são removidos', () {
      expect(_applyNumeric('11 222 333 0001'), '11.222.333/0001');
    });
  });

  group('CnpjMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = CnpjMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '11222333000181'),
      );
      const formatted = '11.222.333/0001-81';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  group('CnpjMask — compatibilidade com AllValidations.isCnpj', () {
    test('CNPJ mascarado é reconhecido como válido', () {
      // CNPJ válido: 11.222.333/0001-81
      final masked = _applyNumeric('11222333000181');
      expect(masked, '11.222.333/0001-81');
      expect(AllValidations.isCnpj(masked), isTrue);
    });
  });

  // ── CnpjAlfaMask (alfanumérico 2026) ─────────────────────────────────────

  group('CnpjAlfaMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyAlfa(''), ''));

    test('1 char', () => expect(_applyAlfa('A'), 'A'));

    test('2 chars — sem ponto ainda', () {
      expect(_applyAlfa('AB'), 'AB');
    });

    test('3 chars — insere primeiro ponto', () {
      expect(_applyAlfa('AB1'), 'AB.1');
    });

    test('5 chars', () => expect(_applyAlfa('AB123'), 'AB.123'));

    test('6 chars — insere segundo ponto', () {
      expect(_applyAlfa('AB123C'), 'AB.123.C');
    });

    test('8 chars', () => expect(_applyAlfa('AB123CDE'), 'AB.123.CDE'));

    test('9 chars — insere barra', () {
      expect(_applyAlfa('AB123CDE0'), 'AB.123.CDE/0');
    });

    test('12 chars', () {
      expect(_applyAlfa('AB123CDE0001'), 'AB.123.CDE/0001');
    });

    test('13 chars — insere traço', () {
      expect(_applyAlfa('AB123CDE00013'), 'AB.123.CDE/0001-3');
    });

    test('14 chars — CNPJ alfanumérico completo', () {
      expect(_applyAlfa('AB123CDE000139'), 'AB.123.CDE/0001-39');
    });
  });

  group('CnpjAlfaMask — conversão e filtragem', () {
    test('minúsculas são convertidas para maiúsculas', () {
      expect(_applyAlfa('ab123cde'), 'AB.123.CDE');
    });

    test('caracteres especiais são removidos', () {
      expect(_applyAlfa('AB!@#123'), 'AB.123');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      expect(_applyAlfa('AB.123.CDE/0001-39'), 'AB.123.CDE/0001-39');
    });

    test('mistura de letras e dígitos em ordem alternada', () {
      expect(_applyAlfa('A1B2C3'), 'A1.B2C.3');
    });
  });

  group('CnpjAlfaMask — truncamento', () {
    test('mais de 14 chars são ignorados', () {
      expect(_applyAlfa('AB123CDE000139X'), 'AB.123.CDE/0001-39');
    });
  });

  group('CnpjAlfaMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = CnpjAlfaMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: 'AB123CDE000139'),
      );
      const formatted = 'AB.123.CDE/0001-39';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
