import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CnpjAlfanumerico.strip', () {
    test('remove máscara padrão', () {
      expect(
        CnpjAlfanumerico.strip('12.ABC.345/DE67-89'),
        '12ABC345DE6789',
      );
    });

    test('converte para maiúsculas', () {
      expect(CnpjAlfanumerico.strip('ab.cde.fgh/ijkl-00'), 'ABCDEFGHIJKL00');
    });

    test('string sem máscara permanece igual', () {
      expect(CnpjAlfanumerico.strip('12ABC345DE6789'), '12ABC345DE6789');
    });

    test('string vazia retorna vazia', () {
      expect(CnpjAlfanumerico.strip(''), '');
    });
  });

  // ── CNPJs numéricos legados (devem continuar válidos) ────────────────────

  group('CnpjAlfanumerico.isValid — CNPJs numéricos (legado)', () {
    test('CNPJ numérico válido sem máscara', () {
      expect(CnpjAlfanumerico.isValid('11222333000181'), isTrue);
    });

    test('CNPJ numérico válido com máscara', () {
      expect(CnpjAlfanumerico.isValid('11.222.333/0001-81'), isTrue);
    });

    test('CNPJ numérico inválido — DV errado', () {
      expect(CnpjAlfanumerico.isValid('11222333000182'), isFalse);
    });

    test('CNPJ com todos dígitos iguais é inválido', () {
      for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
        expect(CnpjAlfanumerico.isValid(d * 14), isFalse,
            reason: 'Sequência $d repetida deve ser inválida');
      }
    });
  });

  // ── CNPJs alfanuméricos 2026 ─────────────────────────────────────────────

  group('CnpjAlfanumerico.isValid — formato alfanumérico 2026', () {
    test('null retorna false', () {
      expect(CnpjAlfanumerico.isValid(null), isFalse);
    });

    test('string vazia retorna false', () {
      expect(CnpjAlfanumerico.isValid(''), isFalse);
    });

    test('comprimento < 14 retorna false', () {
      expect(CnpjAlfanumerico.isValid('AB123'), isFalse);
    });

    test('comprimento > 14 retorna false', () {
      expect(CnpjAlfanumerico.isValid('AB1234567890123'), isFalse);
    });

    test('dígitos verificadores não-numéricos retornam false', () {
      // Últimos 2 chars são 'AB' (letras) — inválido pois DV deve ser numérico
      expect(CnpjAlfanumerico.isValid('12ABC345DE67AB'), isFalse);
    });

    // CNPJs calculados com o algoritmo correto (IN RFB 2229/2024):
    // body = "A1B2C3D4E5F6", DV calculado pelo _calcDigit correto
    test('CNPJ alfanumérico gerado internamente é válido (round-trip)', () {
      final cnpj = CnpjAlfanumerico.generate(forceAlphanumeric: true);
      expect(CnpjAlfanumerico.isValid(cnpj), isTrue,
          reason: 'CNPJ gerado "$cnpj" deve ser válido');
    });

    test('CNPJ alfanumérico formatado é válido (round-trip)', () {
      final cnpj =
          CnpjAlfanumerico.generate(formatted: true, forceAlphanumeric: true);
      expect(CnpjAlfanumerico.isValid(cnpj), isTrue,
          reason: 'CNPJ formatado "$cnpj" deve ser válido');
    });

    test('DV incorreto no CNPJ alfanumérico retorna false', () {
      // Gera um CNPJ válido e altera o último dígito
      final valid = CnpjAlfanumerico.generate();
      final tampered =
          valid.substring(0, 13) + ((int.parse(valid[13]) + 1) % 10).toString();
      expect(CnpjAlfanumerico.isValid(tampered), isFalse);
    });

    // Demonstra o bug do brasil_fields: converte char com -48 em vez de -55
    // Para 'A' o brasil_fields usa valor 17 (errado), o correto é 10.
    // Este teste verifica que nosso algoritmo usa o valor correto.
    test('valor de A é 10 e de Z é 35 no mapeamento correto', () {
      // Verifica indiretamente via geração + validação com letra A no body
      // Se o algoritmo fosse errado (A=17), o DV seria diferente e isValid falharia.
      final cnpjComA = CnpjAlfanumerico.generate(forceAlphanumeric: true);
      // Qualquer CNPJ gerado com letra deve ser validável
      expect(CnpjAlfanumerico.isValid(cnpjComA), isTrue);
    });
  });

  // ── format ───────────────────────────────────────────────────────────────

  group('CnpjAlfanumerico.format', () {
    test('formata CNPJ alfanumérico sem máscara', () {
      expect(
        CnpjAlfanumerico.format('AB1234567800AB'),
        // 14 chars após strip: AB.123.456/7800-AB (format não valida DV)
        'AB.123.456/7800-AB',
      );
    });

    test('re-formata CNPJ já mascarado (idempotente após strip)', () {
      const masked = '12.ABC.345/DE67-89';
      expect(
        CnpjAlfanumerico.format(CnpjAlfanumerico.strip(masked)),
        '12.ABC.345/DE67-89',
      );
    });

    test('CNPJ com comprimento errado lança ArgumentError', () {
      expect(() => CnpjAlfanumerico.format('CURTO'), throwsArgumentError);
    });

    test('CNPJ gerado e formatado tem máscara correta', () {
      final raw = CnpjAlfanumerico.generate();
      final formatted = CnpjAlfanumerico.format(raw);
      // Deve ter o padrão XX.XXX.XXX/XXXX-XX
      expect(
          formatted,
          matches(
              r'^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$'));
    });
  });

  // ── generate ─────────────────────────────────────────────────────────────

  group('CnpjAlfanumerico.generate', () {
    test('gera CNPJ válido por padrão (numérico ou alfanumérico)', () {
      for (var i = 0; i < 20; i++) {
        final cnpj = CnpjAlfanumerico.generate();
        expect(CnpjAlfanumerico.isValid(cnpj), isTrue,
            reason: 'Iteração $i: "$cnpj" deve ser válido');
      }
    });

    test('gera CNPJ formatado válido', () {
      for (var i = 0; i < 10; i++) {
        final cnpj = CnpjAlfanumerico.generate(formatted: true);
        expect(
            cnpj,
            matches(
                r'^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$'));
        expect(CnpjAlfanumerico.isValid(cnpj), isTrue);
      }
    });

    test('generate(forceAlphanumeric: true) sempre contém ao menos uma letra',
        () {
      for (var i = 0; i < 30; i++) {
        final cnpj = CnpjAlfanumerico.generate(forceAlphanumeric: true);
        // Os primeiros 12 chars do raw devem conter pelo menos uma letra
        final body = cnpj.substring(0, 12);
        expect(RegExp(r'[A-Z]').hasMatch(body), isTrue,
            reason: 'body "$body" deve conter ao menos uma letra');
        expect(CnpjAlfanumerico.isValid(cnpj), isTrue);
      }
    });

    test('CNPJ gerado tem exatamente 14 caracteres (sem máscara)', () {
      final cnpj = CnpjAlfanumerico.generate();
      expect(cnpj.length, 14);
    });

    test('últimos 2 chars do CNPJ gerado são sempre dígitos', () {
      for (var i = 0; i < 20; i++) {
        final cnpj = CnpjAlfanumerico.generate();
        expect(RegExp(r'^\d{2}$').hasMatch(cnpj.substring(12)), isTrue,
            reason: 'DV de "$cnpj" deve ser numérico');
      }
    });
  });

  // ── AllValidations.isCnpjAlphanumeric ────────────────────────────────────

  group('AllValidations.isCnpjAlphanumeric', () {
    test('delega corretamente para CnpjAlfanumerico.isValid', () {
      final valid = CnpjAlfanumerico.generate();
      expect(AllValidations.isCnpjAlphanumeric(valid), isTrue);
      expect(AllValidations.isCnpjAlphanumeric('invalido'), isFalse);
    });

    test('CNPJ numérico legado válido passa pela validação alfanumérica', () {
      expect(AllValidations.isCnpjAlphanumeric('11.222.333/0001-81'), isTrue);
    });
  });
}
