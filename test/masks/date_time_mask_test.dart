import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _applyDate(String text) {
  const mask = DateMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

String _applyTime(String text) {
  const mask = TimeMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── DateMask ──────────────────────────────────────────────────────────────────

void main() {
  group('DateMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyDate(''), ''));

    test('1 dígito', () => expect(_applyDate('0'), '0'));

    test('2 dígitos — dia completo, sem barra', () {
      expect(_applyDate('01'), '01');
    });

    test('3 dígitos — insere primeira barra', () {
      expect(_applyDate('011'), '01/1');
    });

    test('4 dígitos — mês completo', () {
      expect(_applyDate('0107'), '01/07');
    });

    test('5 dígitos — insere segunda barra', () {
      expect(_applyDate('01072'), '01/07/2');
    });

    test('6 dígitos', () => expect(_applyDate('010720'), '01/07/20'));

    test('7 dígitos', () => expect(_applyDate('0107202'), '01/07/202'));

    test('8 dígitos — data completa', () {
      expect(_applyDate('01072026'), '01/07/2026');
    });
  });

  group('DateMask — truncamento', () {
    test('mais de 8 dígitos são ignorados', () {
      expect(_applyDate('010720261'), '01/07/2026');
    });

    test('12 dígitos → apenas os 8 primeiros', () {
      expect(_applyDate('010720261234'), '01/07/2026');
    });
  });

  group('DateMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyDate('abc'), '');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      expect(_applyDate('01/07/2026'), '01/07/2026');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_applyDate('0a1b07'), '01/07');
    });

    test('espaços são removidos', () {
      expect(_applyDate('01 07 2026'), '01/07/2026');
    });
  });

  group('DateMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = DateMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '01072026'),
      );
      const formatted = '01/07/2026';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  group('DateMask — compatibilidade com BrData.validate', () {
    test('data mascarada válida é reconhecida por BrData', () {
      final masked = _applyDate('26062026');
      expect(masked, '26/06/2026');
      expect(BrData.validate(masked), isTrue);
    });

    test('data mascarada de fevereiro em ano bissexto é válida', () {
      final masked = _applyDate('29022024');
      expect(masked, '29/02/2024');
      expect(BrData.validate(masked), isTrue);
    });
  });

  // ── TimeMask ──────────────────────────────────────────────────────────────────

  group('TimeMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyTime(''), ''));

    test('1 dígito', () => expect(_applyTime('1'), '1'));

    test('2 dígitos — hora completa, sem dois-pontos', () {
      expect(_applyTime('14'), '14');
    });

    test('3 dígitos — insere dois-pontos', () {
      expect(_applyTime('143'), '14:3');
    });

    test('4 dígitos — hora completa', () {
      expect(_applyTime('1430'), '14:30');
    });

    test('meia-noite', () => expect(_applyTime('0000'), '00:00'));

    test('final do dia', () => expect(_applyTime('2359'), '23:59'));
  });

  group('TimeMask — truncamento', () {
    test('mais de 4 dígitos são ignorados', () {
      expect(_applyTime('14305'), '14:30');
    });
  });

  group('TimeMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyTime('abc'), '');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      expect(_applyTime('14:30'), '14:30');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_applyTime('1a4b'), '14');
    });
  });

  group('TimeMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = TimeMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1430'),
      );
      const formatted = '14:30';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });
}
