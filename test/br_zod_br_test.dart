import 'package:all_validations_br/src/br_zod/validations/br.dart' as br;
import 'package:all_validations_br/src/br_zod/br_zod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── CPF ──────────────────────────────────────────────────────
  group('isCpf', () {
    test('válido com pontuação',
        () => expect(br.isCpf('529.982.247-25'), isTrue));
    test('válido sem pontuação', () => expect(br.isCpf('52998224725'), isTrue));
    test('dígito errado', () => expect(br.isCpf('529.982.247-26'), isFalse));
    test('todos iguais', () => expect(br.isCpf('111.111.111-11'), isFalse));
    test('menos de 11 dígitos', () => expect(br.isCpf('529.982.247'), isFalse));
    test('null', () => expect(br.isCpf(null), isFalse));
  });

  // ── CNPJ ─────────────────────────────────────────────────────
  group('isCnpj', () {
    test('válido com máscara',
        () => expect(br.isCnpj('11.222.333/0001-81'), isTrue));
    test('válido sem máscara',
        () => expect(br.isCnpj('11222333000181'), isTrue));
    test('dígito errado',
        () => expect(br.isCnpj('11.222.333/0001-82'), isFalse));
    test('todos iguais', () => expect(br.isCnpj('00000000000000'), isFalse));
    test('null', () => expect(br.isCnpj(null), isFalse));
  });

  // ── CNPJ Alfanumérico ─────────────────────────────────────────
  group('isCnpjAlfa', () {
    test('puramente numérico (legado) válido', () {
      // Gerado pelo CnpjAlfanumerico.generate() — algoritmo compatível
      expect(br.isCnpjAlfa('11.222.333/0001-81'), isTrue);
    });
    test('DV inválido',
        () => expect(br.isCnpjAlfa('11.222.333/0001-82'), isFalse));
    test('14 chars iguais',
        () => expect(br.isCnpjAlfa('AAAAAAAA0001AA'), isFalse));
    test('DV com letra (inválido)',
        () => expect(br.isCnpjAlfa('11222333000AB1'), isFalse));
    test('null', () => expect(br.isCnpjAlfa(null), isFalse));
  });

  // ── CPF ou CNPJ ───────────────────────────────────────────────
  group('isCpfOuCnpj', () {
    test('CPF válido', () => expect(br.isCpfOuCnpj('529.982.247-25'), isTrue));
    test('CNPJ válido',
        () => expect(br.isCpfOuCnpj('11.222.333/0001-81'), isTrue));
    test('ambos inválidos', () => expect(br.isCpfOuCnpj('123'), isFalse));
  });

  // ── CEP ───────────────────────────────────────────────────────
  group('isCep', () {
    test('com hífen', () => expect(br.isCep('01310-100'), isTrue));
    test('sem hífen', () => expect(br.isCep('01310100'), isTrue));
    test('7 dígitos', () => expect(br.isCep('0131010'), isFalse));
    test('9 dígitos', () => expect(br.isCep('013101000'), isFalse));
    test('com letras', () => expect(br.isCep('0131A-100'), isFalse));
    test('null', () => expect(br.isCep(null), isFalse));
  });

  // ── RG ────────────────────────────────────────────────────────
  group('isRg', () {
    test('com pontos e traço', () => expect(br.isRg('12.345.678-9'), isTrue));
    test('com X no final', () => expect(br.isRg('12.345.678-X'), isTrue));
    test('sem pontuação', () => expect(br.isRg('123456789'), isTrue));
    test('muito curto', () => expect(br.isRg('1234'), isFalse));
    test('null', () => expect(br.isRg(null), isFalse));
  });

  // ── Placa ─────────────────────────────────────────────────────
  group('isPlaca', () {
    test('formato antigo ABC-1234',
        () => expect(br.isPlaca('ABC-1234'), isTrue));
    test('formato antigo sem hífen',
        () => expect(br.isPlaca('ABC1234'), isTrue));
    test('Mercosul ABC1D23', () => expect(br.isPlaca('ABC1D23'), isTrue));
    test('minúscula inválida', () => expect(br.isPlaca('abc1234'), isFalse));
    test('formato errado', () => expect(br.isPlaca('AB-1234'), isFalse));
    test('null', () => expect(br.isPlaca(null), isFalse));
  });

  // ── CNH ───────────────────────────────────────────────────────
  group('isCnh', () {
    test('válida', () => expect(br.isCnh('84718735264'), isTrue));
    test('todos iguais', () => expect(br.isCnh('11111111111'), isFalse));
    test('10 dígitos', () => expect(br.isCnh('8471873526'), isFalse));
    test('DV errado', () => expect(br.isCnh('84718735265'), isFalse));
    test('null', () => expect(br.isCnh(null), isFalse));
  });

  // ── RENAVAM ───────────────────────────────────────────────────
  group('isRenavam', () {
    test(
        '11 dígitos válido', () => expect(br.isRenavam('97832655694'), isTrue));
    test('9 dígitos válido', () => expect(br.isRenavam('732655694'), isTrue));
    test('todos iguais', () => expect(br.isRenavam('11111111111'), isFalse));
    test('DV errado', () => expect(br.isRenavam('97832655695'), isFalse));
    test('null', () => expect(br.isRenavam(null), isFalse));
  });

  // ── PIS/PASEP ─────────────────────────────────────────────────
  group('isPisPasep', () {
    test('válido', () => expect(br.isPisPasep('12345678919'), isTrue));
    test('todos iguais', () => expect(br.isPisPasep('11111111111'), isFalse));
    test('10 dígitos', () => expect(br.isPisPasep('1234567891'), isFalse));
    test('DV errado', () => expect(br.isPisPasep('12345678910'), isFalse));
    test('null', () => expect(br.isPisPasep(null), isFalse));
  });

  // ── Título de Eleitor ─────────────────────────────────────────
  group('isTituloEleitor', () {
    test('SP válido', () => expect(br.isTituloEleitor('906701490856'), isTrue));
    test('estado inválido (00)',
        () => expect(br.isTituloEleitor('906701490056'), isFalse));
    test('estado inválido (29)',
        () => expect(br.isTituloEleitor('906701492956'), isFalse));
    test('todos iguais',
        () => expect(br.isTituloEleitor('111111111111'), isFalse));
    test(
        '11 dígitos', () => expect(br.isTituloEleitor('90670149085'), isFalse));
    test('null', () => expect(br.isTituloEleitor(null), isFalse));
  });

  // ── CNS ───────────────────────────────────────────────────────
  group('isCns', () {
    test('definitivo válido (inicia com 7)', () {
      expect(br.isCns('700616457492003'), isTrue);
    });
    test('provisório válido (inicia com 1)', () {
      expect(br.isCns('144477462150010'), isTrue);
    });
    test('14 dígitos', () => expect(br.isCns('70061645749200'), isFalse));
    test('inicia com 3 (inválido)',
        () => expect(br.isCns('300616457492003'), isFalse));
    test('soma inválida', () => expect(br.isCns('700616457492004'), isFalse));
    test('null', () => expect(br.isCns(null), isFalse));
  });

  // ── BrZod fluente — BR ────────────────────────────────────────
  group('BrZod encadeado — validações BR', () {
    test('cpf() — válido', () {
      expect(BrZod().required().cpf().build('529.982.247-25'), isNull);
    });
    test('cpf() — inválido', () {
      expect(BrZod().required().cpf().build('111.111.111-11'), isNotNull);
    });
    test('cnpj() — válido', () {
      expect(BrZod().required().cnpj().build('11.222.333/0001-81'), isNull);
    });
    test('cnpj() — inválido', () {
      expect(BrZod().required().cnpj().build('00.000.000/0000-00'), isNotNull);
    });
    test('cpfOuCnpj() — CPF', () {
      expect(BrZod().required().cpfOuCnpj().build('529.982.247-25'), isNull);
    });
    test('cpfOuCnpj() — CNPJ', () {
      expect(
          BrZod().required().cpfOuCnpj().build('11.222.333/0001-81'), isNull);
    });
    test('cep() — válido', () {
      expect(BrZod().required().cep().build('01310-100'), isNull);
    });
    test('cep() — inválido', () {
      expect(BrZod().required().cep().build('0131'), isNotNull);
    });
    test('placa() — antigo', () {
      expect(BrZod().required().placa().build('ABC-1234'), isNull);
    });
    test('placa() — Mercosul', () {
      expect(BrZod().required().placa().build('ABC1D23'), isNull);
    });
    test('placa() — inválido', () {
      expect(BrZod().required().placa().build('AB-123'), isNotNull);
    });
    test('cnh() — válida', () {
      expect(BrZod().required().cnh().build('84718735264'), isNull);
    });
    test('cns() — válido', () {
      expect(BrZod().required().cns().build('700616457492003'), isNull);
    });
    test('cns() — inválido', () {
      expect(BrZod().required().cns().build('123456789012345'), isNotNull);
    });
    test('mensagem customizada', () {
      expect(
        BrZod().required().cpf('Informe um CPF válido').build('111.111.111-11'),
        equals('Informe um CPF válido'),
      );
    });
    test('optional + cpf — vazio ok', () {
      expect(BrZod().optional().cpf().build(''), isNull);
    });
    test('optional + cpf — preenchido inválido', () {
      expect(BrZod().optional().cpf().build('111.111.111-11'), isNotNull);
    });
  });
}
