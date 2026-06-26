import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── format ────────────────────────────────────────────────────────────────

  group('BrData.format', () {
    test('formata data com zero à esquerda', () {
      expect(BrData.format(DateTime(2026, 7, 1)), '01/07/2026');
    });

    test('formata data sem zero à esquerda desnecessário', () {
      expect(BrData.format(DateTime(2026, 12, 25)), '25/12/2026');
    });

    test('formata dia e mês de dois dígitos', () {
      expect(BrData.format(DateTime(2000, 1, 1)), '01/01/2000');
    });
  });

  group('BrData.formatMonthYear', () {
    test('formata mês e ano', () {
      expect(BrData.formatMonthYear(DateTime(2026, 7, 15)), '07/2026');
    });

    test('mês único dígito recebe zero à esquerda', () {
      expect(BrData.formatMonthYear(DateTime(2026, 3, 10)), '03/2026');
    });
  });

  group('BrData.formatDayMonth', () {
    test('formata dia e mês', () {
      expect(BrData.formatDayMonth(DateTime(2026, 7, 4)), '04/07');
    });
  });

  group('BrData.formatTime', () {
    test('formata hora, minuto e segundo com zeros', () {
      expect(BrData.formatTime(DateTime(2026, 1, 1, 8, 5, 3)), '08:05:03');
    });

    test('formata meia-noite', () {
      expect(BrData.formatTime(DateTime(2026, 1, 1, 0, 0, 0)), '00:00:00');
    });
  });

  group('BrData.formatTimeShort', () {
    test('formata hora e minuto', () {
      expect(BrData.formatTimeShort(DateTime(2026, 1, 1, 23, 59)), '23:59');
    });

    test('hora única com zero à esquerda', () {
      expect(BrData.formatTimeShort(DateTime(2026, 1, 1, 9, 5)), '09:05');
    });
  });

  // ── parse ─────────────────────────────────────────────────────────────────

  group('BrData.parse', () {
    test('parseia "01/07/2026" corretamente', () {
      final dt = BrData.parse('01/07/2026');
      expect(dt.day, 1);
      expect(dt.month, 7);
      expect(dt.year, 2026);
    });

    test('parseia "25/12/2000"', () {
      final dt = BrData.parse('25/12/2000');
      expect(dt.day, 25);
      expect(dt.month, 12);
      expect(dt.year, 2000);
    });

    test('formato errado lança FormatException', () {
      expect(() => BrData.parse('2026-07-01'), throwsFormatException);
      expect(() => BrData.parse('31-12-2026'), throwsFormatException);
    });

    test('data inexistente lança FormatException', () {
      // 31/02 não existe
      expect(() => BrData.parse('31/02/2024'), throwsFormatException);
    });

    test('mês inválido lança FormatException', () {
      expect(() => BrData.parse('01/13/2024'), throwsFormatException);
    });

    test('round-trip format → parse', () {
      final original = DateTime(2026, 6, 26);
      final parsed = BrData.parse(BrData.format(original));
      expect(parsed.day, original.day);
      expect(parsed.month, original.month);
      expect(parsed.year, original.year);
    });
  });

  group('BrData.parseWithTime', () {
    test('parseia "26/06/2026 14:30"', () {
      final dt = BrData.parseWithTime('26/06/2026 14:30');
      expect(dt.day, 26);
      expect(dt.month, 6);
      expect(dt.year, 2026);
      expect(dt.hour, 14);
      expect(dt.minute, 30);
    });

    test('formato sem espaço lança FormatException', () {
      expect(() => BrData.parseWithTime('26/06/2026'), throwsFormatException);
    });
  });

  // ── validate ──────────────────────────────────────────────────────────────

  group('BrData.validate', () {
    test('data válida retorna true', () {
      expect(BrData.validate('26/06/2026'), isTrue);
    });

    test('29/02 em ano bissexto é válido', () {
      expect(BrData.validate('29/02/2024'), isTrue);
    });

    test('29/02 em ano não-bissexto é inválido', () {
      expect(BrData.validate('29/02/2023'), isFalse);
    });

    test('31/04 é inválido (abril tem 30 dias)', () {
      expect(BrData.validate('31/04/2026'), isFalse);
    });

    test('mês 13 é inválido', () {
      expect(BrData.validate('01/13/2026'), isFalse);
    });

    test('formato errado retorna false', () {
      expect(BrData.validate('2026-06-26'), isFalse);
    });

    test('string vazia retorna false', () {
      expect(BrData.validate(''), isFalse);
    });

    test('01/01/2000 válido', () {
      expect(BrData.validate('01/01/2000'), isTrue);
    });
  });
}
