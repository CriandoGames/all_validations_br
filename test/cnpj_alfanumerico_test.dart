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

    // Round-trip apenas prova consistência interna (gerar e validar com o
    // mesmo algoritmo) — não prova que o algoritmo está correto perante a
    // especificação oficial. Os testes com vetores independentes abaixo
    // (grupo "vetores oficiais") são a prova real.
    test('CNPJ com letra no body é validável (round-trip)', () {
      final cnpjComA = CnpjAlfanumerico.generate(forceAlphanumeric: true);
      expect(CnpjAlfanumerico.isValid(cnpjComA), isTrue);
    });
  });

  // ── Vetores oficiais / independentes ──────────────────────────────────────
  //
  // Fonte: SERPRO, "Cálculo dos dígitos verificadores de CNPJ alfanumérico"
  // (https://www.serpro.gov.br/menu/noticias/videos/calculodvcnpjalfanaumerico.pdf),
  // que reproduz a regra da Nota Técnica Conjunta 2025.001 / IN RFB 2229/2024:
  // cada caractere vira "valor ASCII − 48" (dígitos 0–9, letras A=17…Z=42),
  // módulo 11, pesos 2–9 da direita para a esquerda.
  //
  // Bug confirmado: a implementação anterior usava `codeUnit - 55` para
  // letras (A=10…Z=35, esquema base-36), calculando DV1=4 em vez do DV1=3
  // oficial para o corpo "12ABC34501DE" — rejeitando um CNPJ alfanumérico
  // legítimo.
  group('CnpjAlfanumerico — vetores oficiais (independentes do algoritmo)', () {
    test('exemplo oficial SERPRO: 12ABC34501DE35', () {
      expect(CnpjAlfanumerico.isValid('12ABC34501DE35'), isTrue);
      expect(CnpjAlfanumerico.isValid('12.ABC.345/01DE-35'), isTrue);
    });

    test('reproduz o bug: DV calculado com -55 (10 para A) é rejeitado', () {
      // Antes da correção, isValid('12ABC34501DE35') retornava false porque
      // o DV1 calculado com A=10 (em vez de A=17) dava 4, não 3.
      expect(CnpjAlfanumerico.isValid('12ABC34501DE34'), isFalse);
    });

    test('segundo vetor independente: AB123456789C30', () {
      // Calculado manualmente com o algoritmo oficial (valor ASCII - 48,
      // pesos 2-9 da direita para a esquerda, módulo 11):
      // body="AB123456789C" -> DV1=3, DV2=0
      expect(CnpjAlfanumerico.isValid('AB123456789C30'), isTrue);
    });

    test('letras minúsculas são aceitas (normalizadas para maiúsculas)', () {
      expect(CnpjAlfanumerico.isValid('12abc34501de35'), isTrue);
    });

    test('caracteres proibidos não são removidos para formar um CNPJ válido',
        () {
      // Regressão: isValid() usava strip indiscriminadamente, aceitando lixo
      // ao redor de um documento válido e qualquer combinação de separadores.
      expect(CnpjAlfanumerico.isValid('@12ABC34501DE35'), isFalse);
      expect(CnpjAlfanumerico.isValid('12ABC34501DE35!'), isFalse);
      expect(CnpjAlfanumerico.isValid('12-ABC-345-01DE-35'), isFalse);
    });

    test('CNPJ numérico legado continua correto com o algoritmo unificado', () {
      // Todos os caracteres são dígitos, então -48 é idêntico em ambas as
      // versões do algoritmo — serve de guarda contra regressão no legado.
      expect(CnpjAlfanumerico.isValid('11222333000181'), isTrue);
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
