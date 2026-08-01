import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _applyExpiry2(String text) {
  const mask = ExpiryMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

String _applyCard(String text) {
  const mask = CardMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

String _applyExpiry(String text) {
  const mask = CardExpiryMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── CardMask ──────────────────────────────────────────────────────────────────

void main() {
  group('CardMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyCard(''), ''));

    test('1 dígito', () => expect(_applyCard('4'), '4'));

    test('4 dígitos — primeiro grupo completo, sem espaço', () {
      expect(_applyCard('4111'), '4111');
    });

    test('5 dígitos — insere primeiro espaço', () {
      expect(_applyCard('41111'), '4111 1');
    });

    test('8 dígitos — segundo grupo completo', () {
      expect(_applyCard('41111111'), '4111 1111');
    });

    test('9 dígitos — insere segundo espaço', () {
      expect(_applyCard('411111111'), '4111 1111 1');
    });

    test('12 dígitos — terceiro grupo completo', () {
      expect(_applyCard('411111111111'), '4111 1111 1111');
    });

    test('13 dígitos — insere terceiro espaço', () {
      expect(_applyCard('4111111111111'), '4111 1111 1111 1');
    });

    test('16 dígitos — cartão completo', () {
      expect(_applyCard('4111111111111111'), '4111 1111 1111 1111');
    });
  });

  group('CardMask — truncamento', () {
    test('mais de 16 dígitos são ignorados', () {
      expect(_applyCard('41111111111111119'), '4111 1111 1111 1111');
    });

    test('20 dígitos → apenas os 16 primeiros', () {
      expect(_applyCard('41111111111111119999'), '4111 1111 1111 1111');
    });
  });

  group('CardMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyCard('abc'), '');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      expect(_applyCard('4111 1111 1111 1111'), '4111 1111 1111 1111');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_applyCard('4a1b1c1'), '4111');
    });

    test('hífens e traços removidos (paste de número com formatação diferente)',
        () {
      expect(_applyCard('4111-1111-1111-1111'), '4111 1111 1111 1111');
    });
  });

  group('CardMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
      const mask = CardMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '4111111111111111'),
      );
      const formatted = '4111 1111 1111 1111';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });
  });

  // ── CardExpiryMask ────────────────────────────────────────────────────────────

  group('CardExpiryMask — progressão da máscara', () {
    test('vazio → vazio', () => expect(_applyExpiry(''), ''));

    test('1 dígito', () => expect(_applyExpiry('1'), '1'));

    test('2 dígitos — mês completo, sem barra', () {
      expect(_applyExpiry('12'), '12');
    });

    test('3 dígitos — insere barra', () {
      expect(_applyExpiry('122'), '12/2');
    });

    test('4 dígitos — validade completa', () {
      expect(_applyExpiry('1224'), '12/24');
    });

    test('mês 01', () => expect(_applyExpiry('0128'), '01/28'));

    test('mês 12', () => expect(_applyExpiry('1299'), '12/99'));
  });

  group('CardExpiryMask — truncamento', () {
    test('mais de 6 dígitos são ignorados', () {
      expect(_applyExpiry('1220249'), '12/2024');
    });
  });

  group('CardExpiryMask — filtragem de caracteres', () {
    test('letras são ignoradas', () {
      expect(_applyExpiry('abc'), '');
    });

    test('entrada já mascarada é re-aplicada corretamente', () {
      expect(_applyExpiry('12/24'), '12/24');
    });

    test('mistura letras e dígitos', () {
      expect(_applyExpiry('1a2'), '12');
    });
  });

  group('CardExpiryMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação', () {
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
  });

  // ── ExpiryMask ────────────────────────────────────────────────────────────────

  group('ExpiryMask — formato MM/AA (até 4 dígitos)', () {
    test('vazio → vazio', () => expect(_applyExpiry2(''), ''));
    test('1 dígito', () => expect(_applyExpiry2('1'), '1'));
    test('2 dígitos — mês completo, sem barra',
        () => expect(_applyExpiry2('12'), '12'));
    test('3 dígitos — insere barra',
        () => expect(_applyExpiry2('122'), '12/2'));
    test('4 dígitos — MM/AA completo',
        () => expect(_applyExpiry2('1224'), '12/24'));
  });

  group('ExpiryMask — formato MM/AAAA (5–6 dígitos)', () {
    test('5 dígitos — ano parcial',
        () => expect(_applyExpiry2('12245'), '12/245'));
    test('6 dígitos — MM/AAAA completo',
        () => expect(_applyExpiry2('122024'), '12/2024'));
    test('7+ dígitos são ignorados além do 6°',
        () => expect(_applyExpiry2('1220249'), '12/2024'));
  });

  group('ExpiryMask — filtragem de caracteres', () {
    test('letras são ignoradas', () => expect(_applyExpiry2('abc'), ''));
    test('entrada já mascarada MM/AA é re-aplicada corretamente',
        () => expect(_applyExpiry2('12/24'), '12/24'));
    test('entrada já mascarada MM/AAAA é re-aplicada corretamente',
        () => expect(_applyExpiry2('12/2024'), '12/2024'));
    test('mistura letras e dígitos',
        () => expect(_applyExpiry2('1a2'), '12'));
  });

  group('ExpiryMask — cursor colapsado no final', () {
    test('cursor fica ao final após formatação MM/AA', () {
      const mask = ExpiryMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '1224'),
      );
      const formatted = '12/24';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });

    test('cursor fica ao final após formatação MM/AAAA', () {
      const mask = ExpiryMask();
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
