import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helper ────────────────────────────────────────────────────────────────────

String _apply(String text) {
  const mask = CpfOuCnpjMask();
  return mask
      .formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(text: text),
      )
      .text;
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  // ── Modo CPF (≤ 11 dígitos) ───────────────────────────────────────────────

  group('CpfOuCnpjMask — modo CPF (≤ 11 dígitos)', () {
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

    test('CPF já mascarado é re-aplicado corretamente', () {
      expect(_apply('123.456.789-01'), '123.456.789-01');
    });
  });

  // ── Transição CPF → CNPJ ─────────────────────────────────────────────────

  group('CpfOuCnpjMask — transição CPF → CNPJ', () {
    test('12 dígitos — muda para formato CNPJ', () {
      expect(_apply('123456789012'), '12.345.678/9012');
    });

    test('13 dígitos — CNPJ parcial com traço', () {
      expect(_apply('1234567890123'), '12.345.678/9012-3');
    });
  });

  // ── Modo CNPJ (> 11 dígitos) ─────────────────────────────────────────────

  group('CpfOuCnpjMask — modo CNPJ (> 11 dígitos)', () {
    test('14 dígitos — CNPJ completo', () {
      expect(_apply('11222333000181'), '11.222.333/0001-81');
    });

    test('CNPJ já mascarado é re-aplicado corretamente', () {
      expect(_apply('11.222.333/0001-81'), '11.222.333/0001-81');
    });

    test('mais de 14 dígitos são truncados', () {
      expect(_apply('112223330001819'), '11.222.333/0001-81');
    });
  });

  // ── Filtragem de caracteres ───────────────────────────────────────────────

  group('CpfOuCnpjMask — filtragem', () {
    test('letras são ignoradas (modo CPF)', () {
      expect(_apply('abc'), '');
    });

    test('mistura letras e dígitos — mantém só dígitos', () {
      expect(_apply('1a2b3'), '123');
    });

    test('espaços são removidos', () {
      expect(_apply('123 456 789 01'), '123.456.789-01');
    });
  });

  // ── Cursor colapsado no final ─────────────────────────────────────────────

  group('CpfOuCnpjMask — cursor colapsado no final', () {
    test('CPF completo — cursor ao final', () {
      const mask = CpfOuCnpjMask();
      final result = mask.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '12345678901'),
      );
      const formatted = '123.456.789-01';
      expect(result.text, formatted);
      expect(result.selection.baseOffset, formatted.length);
      expect(result.selection.extentOffset, formatted.length);
    });

    test('CNPJ completo — cursor ao final', () {
      const mask = CpfOuCnpjMask();
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

  // ── Compatibilidade com AllValidations ───────────────────────────────────

  group('CpfOuCnpjMask — compatibilidade com AllValidations', () {
    test('CPF mascarado é reconhecido como válido', () {
      final masked = _apply('72855147050');
      expect(masked, '728.551.470-50');
      expect(AllValidations.isCpf(masked), isTrue);
    });

    test('CNPJ mascarado é reconhecido como válido', () {
      final masked = _apply('11222333000181');
      expect(masked, '11.222.333/0001-81');
      expect(AllValidations.isCnpj(masked), isTrue);
    });
  });
}
