/// Suíte de regressão — bugs auditados e corrigidos em all_validations_br.
///
/// Cada grupo documenta: o comportamento incorreto observado antes da
/// correção, o teste que comprova o bug (positivo + negativo + limite) e a
/// causa raiz. Ver relatório da auditoria para detalhes e evidências.
library;

import 'package:all_validations_br/all_validations_br.dart';
import 'package:all_validations_br/br_zod.dart' as zod;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════
  // LOTE 1 — regressões diretas
  // ══════════════════════════════════════════════════════════════════════

  group('Bug: isSHA1 aceitava prefixo/sufixo (regex não ancorada)', () {
    const validSha1 = 'da39a3ee5e6b4b0d3255bfef95601890afd80709';

    test('positivo — hash puro é válido', () {
      expect(AllValidations.isSHA1(validSha1), isTrue);
    });

    test('positivo — formato com dois-pontos (20 pares) é válido', () {
      final colonForm =
          RegExp('.{2}').allMatches(validSha1).map((m) => m.group(0)).join(':');
      expect(AllValidations.isSHA1(colonForm), isTrue);
    });

    test('negativo — reproduz o bug: prefixo antes do hash', () {
      // Antes da correção, isso retornava `true` pois a regex não tinha `^`.
      expect(AllValidations.isSHA1('prefixo$validSha1'), isFalse);
    });

    test('negativo — reproduz o bug: sufixo depois do hash', () {
      // Antes da correção, isso retornava `true` pois a regex não tinha `$`.
      expect(AllValidations.isSHA1('${validSha1}sufixo'), isFalse);
    });

    test('negativo — espaços ao redor', () {
      expect(AllValidations.isSHA1(' $validSha1 '), isFalse);
    });

    test('limite — 39 caracteres (curto demais)', () {
      expect(AllValidations.isSHA1('a' * 39), isFalse);
    });

    test('limite — 41 caracteres (longo demais)', () {
      expect(AllValidations.isSHA1('a' * 41), isFalse);
    });

    test('negativo — caractere não hexadecimal', () {
      expect(AllValidations.isSHA1('g' * 40), isFalse);
    });
  });

  group('Bug: isSHA256 aceitava prefixo/sufixo (regex não ancorada)', () {
    const validSha256 =
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    final valid64 = validSha256.substring(0, 64);

    test('positivo — hash puro é válido', () {
      expect(AllValidations.isSHA256(valid64), isTrue);
    });

    test('positivo — formato com dois-pontos (32 pares) é válido', () {
      final colonForm =
          RegExp('.{2}').allMatches(valid64).map((m) => m.group(0)).join(':');
      expect(AllValidations.isSHA256(colonForm), isTrue);
    });

    test('negativo — reproduz o bug: prefixo antes do hash', () {
      expect(AllValidations.isSHA256('prefixo$valid64'), isFalse);
    });

    test('negativo — reproduz o bug: sufixo depois do hash', () {
      expect(AllValidations.isSHA256('${valid64}sufixo'), isFalse);
    });

    test('limite — 63 caracteres (curto demais)', () {
      expect(AllValidations.isSHA256('a' * 63), isFalse);
    });

    test('limite — 65 caracteres (longo demais)', () {
      expect(AllValidations.isSHA256('a' * 65), isFalse);
    });
  });

  group('Bug: isUUID(null) lançava exceção (força-unwrap de String?)', () {
    test('negativo — reproduz o bug: null não deve lançar, deve ser false', () {
      expect(() => AllValidations.isUUID(null), returnsNormally);
      expect(AllValidations.isUUID(null), isFalse);
    });

    test('negativo — string vazia', () {
      expect(AllValidations.isUUID(''), isFalse);
    });

    test('positivo — versões 3, 4, 5 e all continuam funcionando', () {
      expect(
        AllValidations.isUUID('a3bb189e-8bf9-3888-9912-ace4e6543002', '3'),
        isTrue,
      );
      expect(
        AllValidations.isUUID('7b1e3188-e526-47ec-b7b8-fe390a1a2bee', '4'),
        isTrue,
      );
      expect(
        AllValidations.isUUID('a6edc906-2f9f-5fb2-a373-efac406f0ef2', '5'),
        isTrue,
      );
      expect(
        AllValidations.isUUID('edf06bf4-2c10-11ec-8d3d-0242ac130003', 'all'),
        isTrue,
      );
    });

    test('negativo — versão desconhecida retorna false, não lança', () {
      expect(
        () =>
            AllValidations.isUUID('7b1e3188-e526-47ec-b7b8-fe390a1a2bee', '99'),
        returnsNormally,
      );
      expect(
        AllValidations.isUUID('7b1e3188-e526-47ec-b7b8-fe390a1a2bee', '99'),
        isFalse,
      );
    });

    test('preserva maiúsculas/minúsculas', () {
      expect(
        AllValidations.isUUID('7B1E3188-E526-47EC-B7B8-FE390A1A2BEE', '4'),
        isTrue,
      );
    });
  });

  group('Bug: isRG aceitava conteúdo extra (regex não ancorada no fim)', () {
    test('positivo — RG simples (9 dígitos)', () {
      expect(AllValidations.isRG('222733822'), isTrue);
    });

    test('positivo — RG formatado com dígito verificador X', () {
      expect(AllValidations.isRG('29.385.462-X'), isTrue);
      expect(AllValidations.isRG('29385462X'), isTrue);
    });

    test('negativo — reproduz o bug: sufixo após o RG', () {
      expect(AllValidations.isRG('29.385.462-2qualquer-coisa'), isFalse);
    });

    test('negativo — reproduz o bug: prefixo antes do RG', () {
      expect(AllValidations.isRG('prefixo29.385.462-2'), isFalse);
    });

    test('negativo — reproduz o bug: espaço à direita', () {
      expect(AllValidations.isRG('29.385.462-2 '), isFalse);
    });

    test('limite — dígito verificador com 2 dígitos é inválido', () {
      expect(AllValidations.isRG('992.864.791-74'), isFalse);
    });

    test('negativo — curto demais / não numérico', () {
      expect(AllValidations.isRG('1111'), isFalse);
      expect(AllValidations.isRG('aaaaa'), isFalse);
    });

    test('consistência — BrZod().rg() reproduz o mesmo bug/correção', () {
      expect(zod.BrZod().required().rg().build('29.385.462-2qualquer-coisa'),
          isNotNull);
      expect(zod.BrZod().required().rg().build('29.385.462-2'), isNull);
    });
  });

  group('Bug: isValidBRZip aceitava lixo ao redor do CEP', () {
    test('positivo — os 3 formatos documentados continuam válidos', () {
      expect(AllValidations.isValidBRZip('65092-276'), isTrue);
      expect(AllValidations.isValidBRZip('65092276'), isTrue);
      expect(AllValidations.isValidBRZip('65.092-276'), isTrue);
    });

    test('negativo — reproduz o bug: prefixo de 1 caractere + CEP válido', () {
      // Antes: len==10 (dentro de 8–10) e a regex (não ancorada) encontrava
      // "12345-678" embutido em "a12345-678" → retornava true incorretamente.
      expect(AllValidations.isValidBRZip('a12345-678'), isFalse);
    });

    test('negativo — reproduz o bug: sufixo após o CEP', () {
      expect(AllValidations.isValidBRZip('12345678xyz'), isFalse);
    });

    test('negativo — pontuação errada / grupos errados', () {
      expect(AllValidations.isValidBRZip('650.922.76'), isFalse);
      expect(AllValidations.isValidBRZip('650.922'), isFalse);
      expect(AllValidations.isValidBRZip('1234-5678'), isFalse);
    });

    test('limite — curto e longo demais', () {
      expect(AllValidations.isValidBRZip('1234567'), isFalse);
      expect(AllValidations.isValidBRZip('12345678910'), isFalse);
    });

    test('consistência — AllValidations, ContractValidations e BrZod concordam',
        () {
      const casosValidos = ['65092-276', '65092276', '65.092-276'];
      const casosInvalidos = [
        'a12345-678',
        '12345678xyz',
        '650.922.76',
        '1234-5678',
      ];

      for (final v in [...casosValidos, ...casosInvalidos]) {
        final direct = AllValidations.isValidBRZip(v);
        final contract =
            Contract().requires().isValidBRZip(v, 'cep', 'inválido').isValid;
        final zodResult = zod.BrZod().required().cep().build(v) == null;

        expect(contract, direct,
            reason: 'ContractValidations diverge para "$v"');
        expect(zodResult, direct, reason: 'BrZod diverge para "$v"');
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // LOTE 2 — validações estruturais
  // ══════════════════════════════════════════════════════════════════════

  group('Bug: isURL usava (por engano) uma regex de e-mail', () {
    const validUrls = [
      'https://example.com',
      'http://example.com',
      'https://example.com/path',
      'https://example.com/path?value=1',
      'https://example.com?value=1',
      'https://sub.example.com',
      'http://localhost',
      'http://localhost:8080',
      'http://127.0.0.1',
      'ftp://example.com/file.txt',
    ];

    const invalidUrls = [
      'user@example.com',
      'example.com',
      '://example.com',
      'https://',
      'https:///path',
      'texto qualquer',
      'javascript:alert(1)',
      'data:text/plain,abc',
    ];

    for (final url in validUrls) {
      test('positivo — "$url" é uma URL válida', () {
        expect(AllValidations.isURL(url), isTrue);
      });
    }

    for (final url in invalidUrls) {
      test('negativo — reproduz o bug: "$url" não é uma URL', () {
        // Antes da correção, "user@example.com" retornava true (regex de
        // e-mail) e "https://example.com" retornava false.
        expect(AllValidations.isURL(url), isFalse);
      });
    }

    test('consistência — AllValidations, ContractValidations e BrZod concordam',
        () {
      for (final url in [...validUrls, ...invalidUrls]) {
        final direct = AllValidations.isURL(url);
        final contract =
            Contract().requires().isURL(url, 'url', 'inválida').isValid;
        final zodResult = zod.BrZod().required().url().build(url) == null;

        expect(contract, direct,
            reason: 'ContractValidations diverge para "$url"');
        expect(zodResult, direct, reason: 'BrZod diverge para "$url"');
      }
    });
  });

  group('Bug: telefone com DDD 55 tratado como código de país', () {
    test('positivo — celular com DDD 55 (RS), formatado', () {
      expect(AllValidations.isBrazilianCellPhone('(55) 99123-4567'), isTrue);
    });

    test('positivo — celular com DDD 55, só dígitos (11 dígitos)', () {
      // Antes: startsWith('55') removia os 2 primeiros dígitos
      // incondicionalmente, sobrando só 9 dígitos → comprimento != 11 → false.
      expect(AllValidations.isBrazilianCellPhone('55991234567'), isTrue);
    });

    test('positivo — celular com código de país +55 e DDD 55', () {
      expect(AllValidations.isBrazilianCellPhone('+55 55 99123-4567'), isTrue);
    });

    test('positivo — fixo com DDD 55, formatado', () {
      expect(AllValidations.isBrazilianLandline('(55) 3232-1234'), isTrue);
    });

    test('positivo — fixo com código de país +55 e DDD 55', () {
      expect(AllValidations.isBrazilianLandline('+55 55 3232-1234'), isTrue);
    });

    test('limite — celular com código de país mas DDD diferente de 55', () {
      expect(AllValidations.isBrazilianCellPhone('+55 11 91234-5678'), isTrue);
    });

    test('negativo — DDD inválido continua rejeitado', () {
      expect(AllValidations.isBrazilianCellPhone('+55 01 91234-5678'), isFalse);
    });

    test('negativo — não aceita número sem DDD', () {
      expect(AllValidations.isBrazilianCellPhone('991234567'), isFalse);
      expect(AllValidations.isBrazilianLandline('12345678'), isFalse);
    });

    test('consistência — ContractValidations.isPhoneNumber concorda', () {
      final contract = Contract()
          .requires()
          .isPhoneNumber('55991234567', 'telefone', 'inválido')
          .isValid;
      expect(contract, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════
  // LOTE 3 — CNPJ alfanumérico (conversão de caractere -48 vs -55)
  // ══════════════════════════════════════════════════════════════════════

  group('Bug: conversão de caractere do CNPJ alfanumérico (-55 vs -48)', () {
    // Vetor oficial: SERPRO, "Cálculo dos dígitos verificadores de CNPJ
    // alfanumérico" — body "12ABC34501DE" -> DV "35".
    const officialValid = '12ABC34501DE35';
    const officialFormatted = '12.ABC.345/01DE-35';

    test('positivo — AllValidations.isCnpjAlphanumeric aceita o vetor oficial',
        () {
      expect(AllValidations.isCnpjAlphanumeric(officialValid), isTrue);
      expect(AllValidations.isCnpjAlphanumeric(officialFormatted), isTrue);
    });

    test('negativo — reproduz o bug: DV calculado com A=10 é rejeitado', () {
      expect(AllValidations.isCnpjAlphanumeric('12ABC34501DE34'), isFalse);
    });

    test('consistência — CnpjAlfanumerico, AllValidations e BrZod concordam',
        () {
      const casos = [
        '12ABC34501DE35',
        '12ABC34501DE34', // DV errado
        'AB123456789C30',
        '11222333000181', // numérico legado válido
        '11222333000182', // numérico legado com DV errado
      ];

      for (final v in casos) {
        final pure = CnpjAlfanumerico.isValid(v);
        final direct = AllValidations.isCnpjAlphanumeric(v);
        final zodResult = zod.BrZod().required().cnpjAlfa().build(v) == null;

        expect(direct, pure, reason: 'AllValidations diverge para "$v"');
        expect(zodResult, pure, reason: 'BrZod diverge para "$v"');
      }
    });
  });

  group('Consistência entre APIs — UUID', () {
    const casos = [
      'a3bb189e-8bf9-3888-9912-ace4e6543002',
      'a6edc906',
      '',
    ];

    test('AllValidations.isUUID vs ContractValidations.isUUID', () {
      for (final v in casos) {
        final direct = AllValidations.isUUID(v);
        final contract =
            Contract().requires().isUUID(v, 'uuid', 'inválido').isValid;
        final zodResult = zod.BrZod().required().uuid().build(v) == null;
        expect(contract, direct, reason: 'diverge para "$v"');
        expect(zodResult, direct, reason: 'BrZod diverge para "$v"');
      }
    });
  });

  group('Consistência entre APIs — CPF e CNPJ numérico', () {
    test('CPF concorda entre AllValidations, Contract e BrZod', () {
      const casos = [
        '529.982.247-25',
        '52998224725',
        '529.982.247-26',
        '111.111.111-11',
        '',
      ];

      for (final v in casos) {
        final direct = AllValidations.isCpf(v);
        final contract =
            Contract().requires().isValidCPF(v, 'cpf', 'inválido').isValid;
        final zodResult = zod.BrZod().required().cpf().build(v) == null;

        expect(contract, direct, reason: 'Contract diverge para "$v"');
        expect(zodResult, direct, reason: 'BrZod diverge para "$v"');
      }
    });

    test('CNPJ concorda entre AllValidations, Contract e BrZod', () {
      const casos = [
        '11.222.333/0001-81',
        '11222333000181',
        '11.222.333/0001-82',
        '00.000.000/0000-00',
        '',
      ];

      for (final v in casos) {
        final direct = AllValidations.isCnpj(v);
        final contract =
            Contract().requires().isValidCNPJ(v, 'cnpj', 'inválido').isValid;
        final zodResult = zod.BrZod().required().cnpj().build(v) == null;

        expect(contract, direct, reason: 'Contract diverge para "$v"');
        expect(zodResult, direct, reason: 'BrZod diverge para "$v"');
      }
    });
  });

  group('Consistência entre APIs — documentos brasileiros', () {
    test('placa concorda entre AllValidations e BrZod', () {
      const casos = ['ABC-1234', 'ABC1234', 'ABC1D23', 'abc1234', 'AB-123'];
      for (final v in casos) {
        final direct = AllValidations.isValidBrazilianLicensePlate(v);
        final zodResult = zod.BrZod().required().placa().build(v) == null;
        expect(zodResult, direct, reason: 'diverge para "$v"');
      }
    });

    test('CNH concorda entre AllValidations e BrZod', () {
      const casos = ['84718735264', '84718735265', '11111111111', '123'];
      for (final v in casos) {
        final direct = AllValidations.isCnh(v);
        final zodResult = zod.BrZod().required().cnh().build(v) == null;
        expect(zodResult, direct, reason: 'diverge para "$v"');
      }
    });

    test('RENAVAM concorda entre AllValidations e BrZod', () {
      const casos = ['97832655697', '732655692', '97832655695', '11111111111'];
      for (final v in casos) {
        final direct = AllValidations.isRenavam(v);
        final zodResult = zod.BrZod().required().renavam().build(v) == null;
        expect(zodResult, direct, reason: 'diverge para "$v"');
      }
    });

    test('PIS/PASEP concorda entre AllValidations e BrZod', () {
      const casos = ['12345678919', '12345678910', '11111111111', '123'];
      for (final v in casos) {
        final direct = AllValidations.isPisPasep(v);
        final zodResult = zod.BrZod().required().pisPasep().build(v) == null;
        expect(zodResult, direct, reason: 'diverge para "$v"');
      }
    });

    test('Título de Eleitor concorda entre AllValidations e BrZod', () {
      const casos = ['123456780191', '906701490056', '111111111111', '123'];
      for (final v in casos) {
        final direct = AllValidations.isTituloEleitor(v);
        final zodResult =
            zod.BrZod().required().tituloEleitor().build(v) == null;
        expect(zodResult, direct, reason: 'diverge para "$v"');
      }
    });
  });
}
