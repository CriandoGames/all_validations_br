import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── CPF ───────────────────────────────────────────────────────────────────

  group('BrFormatter.stripCpf', () {
    test('remove pontos e traço', () {
      expect(BrFormatter.stripCpf('529.982.247-25'), '52998224725');
    });

    test('string sem máscara permanece igual', () {
      expect(BrFormatter.stripCpf('52998224725'), '52998224725');
    });

    test('string vazia retorna vazia', () {
      expect(BrFormatter.stripCpf(''), '');
    });
  });

  group('BrFormatter.formatCpf', () {
    test('11 dígitos → máscara correta', () {
      expect(BrFormatter.formatCpf('52998224725'), '529.982.247-25');
    });

    test('remove máscara existente antes de reformatar', () {
      expect(BrFormatter.formatCpf('529.982.247-25'), '529.982.247-25');
    });

    test('menos de 11 dígitos lança ArgumentError', () {
      expect(() => BrFormatter.formatCpf('1234'), throwsArgumentError);
    });

    test('mais de 11 dígitos lança ArgumentError', () {
      expect(() => BrFormatter.formatCpf('123456789012'), throwsArgumentError);
    });
  });

  group('BrFormatter.generateCpf', () {
    test('gera CPF com 11 dígitos por padrão', () {
      final cpf = BrFormatter.generateCpf();
      expect(cpf.length, 11);
      expect(RegExp(r'^\d{11}$').hasMatch(cpf), isTrue);
    });

    test('gera CPF formatado com máscara correta', () {
      final cpf = BrFormatter.generateCpf(formatted: true);
      expect(cpf, matches(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$'));
    });

    test('CPF gerado é válido (round-trip via AllValidations)', () {
      for (var i = 0; i < 20; i++) {
        final cpf = BrFormatter.generateCpf();
        expect(AllValidations.isCpf(cpf), isTrue,
            reason: 'CPF gerado "$cpf" deve ser válido');
      }
    });

    test('CPF formatado gerado é válido', () {
      final cpf = BrFormatter.generateCpf(formatted: true);
      expect(AllValidations.isCpf(cpf), isTrue);
    });

    test('não gera sequências repetidas (111.111.111-11 etc.)', () {
      // Difícil de garantir em 1 chamada; 50 gerações sem sequência repetida
      // confirma que o filtro funciona estatisticamente.
      for (var i = 0; i < 50; i++) {
        final cpf = BrFormatter.generateCpf();
        final allSame = RegExp(r'^(.)\1{10}$').hasMatch(cpf);
        expect(allSame, isFalse, reason: 'CPF "$cpf" é sequência repetida');
      }
    });
  });

  // ── CNPJ numérico ─────────────────────────────────────────────────────────

  group('BrFormatter.stripCnpj', () {
    test('remove máscara completa', () {
      expect(BrFormatter.stripCnpj('11.222.333/0001-81'), '11222333000181');
    });

    test('string sem máscara permanece igual', () {
      expect(BrFormatter.stripCnpj('11222333000181'), '11222333000181');
    });
  });

  group('BrFormatter.formatCnpj', () {
    test('14 dígitos → máscara correta', () {
      expect(BrFormatter.formatCnpj('11222333000181'), '11.222.333/0001-81');
    });

    test('re-formata CNPJ já mascarado', () {
      expect(
          BrFormatter.formatCnpj('11.222.333/0001-81'), '11.222.333/0001-81');
    });

    test('menos de 14 dígitos lança ArgumentError', () {
      expect(
          () => BrFormatter.formatCnpj('1122233300018'), throwsArgumentError);
    });
  });

  group('BrFormatter.generateCnpj', () {
    test('gera CNPJ com 14 dígitos por padrão', () {
      final cnpj = BrFormatter.generateCnpj();
      expect(cnpj.length, 14);
      expect(RegExp(r'^\d{14}$').hasMatch(cnpj), isTrue);
    });

    test('gera CNPJ formatado com máscara correta', () {
      final cnpj = BrFormatter.generateCnpj(formatted: true);
      expect(cnpj, matches(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$'));
    });

    test('CNPJ gerado é válido (round-trip via AllValidations)', () {
      for (var i = 0; i < 20; i++) {
        final cnpj = BrFormatter.generateCnpj();
        expect(AllValidations.isCnpj(cnpj), isTrue,
            reason: 'CNPJ gerado "$cnpj" deve ser válido');
      }
    });
  });

  // ── CEP ───────────────────────────────────────────────────────────────────

  group('BrFormatter.formatCep', () {
    test('8 dígitos → "99999-999"', () {
      expect(BrFormatter.formatCep('01310100'), '01310-100');
    });

    test('remove máscara antes de reformatar', () {
      expect(BrFormatter.formatCep('01310-100'), '01310-100');
    });

    test('menos de 8 dígitos lança ArgumentError', () {
      expect(() => BrFormatter.formatCep('0131010'), throwsArgumentError);
    });
  });

  group('BrFormatter.stripCep', () {
    test('remove traço', () {
      expect(BrFormatter.stripCep('01310-100'), '01310100');
    });
  });

  // ── Telefone ──────────────────────────────────────────────────────────────

  group('BrFormatter.formatPhone', () {
    test('11 dígitos → celular com DDD', () {
      expect(BrFormatter.formatPhone('11999998877'), '(11) 99999-8877');
    });

    test('10 dígitos → fixo com DDD', () {
      expect(BrFormatter.formatPhone('1133334444'), '(11) 3333-4444');
    });

    test('11 dígitos sem DDD', () {
      expect(BrFormatter.formatPhone('11999998877', ddd: false), '99999-8877');
    });

    test('10 dígitos sem DDD', () {
      expect(BrFormatter.formatPhone('1133334444', ddd: false), '3333-4444');
    });

    test('com máscara existente — remove e reformata', () {
      expect(BrFormatter.formatPhone('(11) 99999-8877'), '(11) 99999-8877');
    });

    test('número inválido lança ArgumentError', () {
      expect(() => BrFormatter.formatPhone('1199'), throwsArgumentError);
    });
  });

  group('BrFormatter.extractDdd', () {
    test('extrai DDD de celular', () {
      expect(BrFormatter.extractDdd('11999998877'), '11');
    });

    test('extrai DDD de fixo', () {
      expect(BrFormatter.extractDdd('(21) 3333-4444'), '21');
    });

    test('string curta retorna vazia', () {
      expect(BrFormatter.extractDdd('1'), '');
    });
  });

  // ── Moeda ─────────────────────────────────────────────────────────────────

  group('BrFormatter.formatCurrency', () {
    test('valor simples → "R\$ 1.234,56"', () {
      expect(BrFormatter.formatCurrency(1234.56), 'R\$ 1.234,56');
    });

    test('sem símbolo → "1.234,56"', () {
      expect(BrFormatter.formatCurrency(1234.56, symbol: false), '1.234,56');
    });

    test('sem decimais → "R\$ 1.234"', () {
      expect(BrFormatter.formatCurrency(1234.0, decimals: 0), 'R\$ 1.234');
    });

    test('valor grande → milhões com pontos', () {
      expect(BrFormatter.formatCurrency(85437107.04), 'R\$ 85.437.107,04');
    });

    test('zero → "R\$ 0,00"', () {
      expect(BrFormatter.formatCurrency(0), 'R\$ 0,00');
    });

    test('valor sem milhar → sem ponto', () {
      expect(BrFormatter.formatCurrency(99.9), 'R\$ 99,90');
    });
  });

  group('BrFormatter.parseCurrency', () {
    test('parseia "R\$ 1.234,56" → 1234.56', () {
      expect(BrFormatter.parseCurrency('R\$ 1.234,56'), 1234.56);
    });

    test('parseia sem símbolo "1.234,56" → 1234.56', () {
      expect(BrFormatter.parseCurrency('1.234,56'), 1234.56);
    });

    test('parseia valor grande', () {
      expect(BrFormatter.parseCurrency('R\$ 85.437.107,04'), 85437107.04);
    });

    test('round-trip formatCurrency → parseCurrency', () {
      const value = 12345.67;
      final formatted = BrFormatter.formatCurrency(value);
      expect(BrFormatter.parseCurrency(formatted), value);
    });
  });

  group('BrFormatter.stripCurrencySymbol', () {
    test('remove "R\$ "', () {
      expect(BrFormatter.stripCurrencySymbol('R\$ 1.234,56'), '1.234,56');
    });

    test('string sem símbolo permanece igual', () {
      expect(BrFormatter.stripCurrencySymbol('1.234,56'), '1.234,56');
    });
  });

  // ── KM ────────────────────────────────────────────────────────────────────

  group('BrFormatter.formatKm', () {
    test('85437 → "85.437 km"', () {
      expect(BrFormatter.formatKm(85437), '85.437 km');
    });

    test('valor abaixo de 1000 sem ponto', () {
      expect(BrFormatter.formatKm(999), '999 km');
    });

    test('1000 → "1.000 km"', () {
      expect(BrFormatter.formatKm(1000), '1.000 km');
    });

    test('1000000 → "1.000.000 km"', () {
      expect(BrFormatter.formatKm(1000000), '1.000.000 km');
    });

    test('valor negativo mantém sinal', () {
      expect(BrFormatter.formatKm(-5000), '-5.000 km');
    });
  });
}
