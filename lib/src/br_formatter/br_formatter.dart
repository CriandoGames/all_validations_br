import 'dart:math';

/// Utilitários de formatação para dados tipicamente brasileiros.
///
/// Cobre documentos (CPF, CNPJ, CEP), contatos (telefone, DDD),
/// moeda (R$) e quilometragem — sem dependências externas.
///
/// Veja também [BrData] para formatação de datas e horas.
class BrFormatter {
  BrFormatter._();

  // ── RegExps cacheadas ──────────────────────────────────────────────────────

  static final RegExp _nonDigit = RegExp(r'\D');
  static final RegExp _allSameCpf = RegExp(r'^(.)\1{10}$');
  static final RegExp _currencySymbol = RegExp(r'[R\$\s]');

  // ════════════════════════════════════════════════════════════════════════════
  // CPF
  // ════════════════════════════════════════════════════════════════════════════

  /// Remove a máscara do CPF → apenas dígitos.
  static String stripCpf(String cpf) => cpf.replaceAll(_nonDigit, '');

  /// Formata um CPF (11 dígitos) → `'999.999.999-99'`.
  ///
  /// Lança [ArgumentError] se [cpf] não tiver 11 dígitos após strip.
  static String formatCpf(String cpf) {
    final s = stripCpf(cpf);
    if (s.length != 11) {
      throw ArgumentError.value(
        cpf,
        'cpf',
        'CPF inválido: deve ter 11 dígitos após remover a máscara.',
      );
    }
    return '${s.substring(0, 3)}.${s.substring(3, 6)}'
        '.${s.substring(6, 9)}-${s.substring(9)}';
  }

  /// Gera um CPF válido aleatório.
  ///
  /// - [formatted]: se `true`, retorna no padrão `'999.999.999-99'`.
  static String generateCpf({bool formatted = false}) {
    final rand = Random.secure();
    List<int> d;

    // Rejeita sequências com 11 dígitos iguais (ex.: 111.111.111-11)
    do {
      d = List.generate(9, (_) => rand.nextInt(10));
    } while (_allSameCpf.hasMatch(d.join()));

    // Primeiro DV — pesos 10 a 2
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += d[i] * (10 - i);
    }
    int dv1 = 11 - (sum % 11);
    d.add(dv1 >= 10 ? 0 : dv1);

    // Segundo DV — pesos 11 a 2
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += d[i] * (11 - i);
    }
    int dv2 = 11 - (sum % 11);
    d.add(dv2 >= 10 ? 0 : dv2);

    final cpf = d.join();
    return formatted ? formatCpf(cpf) : cpf;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CNPJ numérico (legado)
  // ════════════════════════════════════════════════════════════════════════════

  /// Remove a máscara do CNPJ → apenas dígitos.
  ///
  /// Para CNPJ alfanumérico use `CnpjAlfanumerico.strip`.
  static String stripCnpj(String cnpj) => cnpj.replaceAll(_nonDigit, '');

  /// Formata um CNPJ numérico (14 dígitos) → `'99.999.999/9999-99'`.
  ///
  /// Para CNPJ alfanumérico 2026, use `CnpjAlfanumerico.format`.
  ///
  /// Lança [ArgumentError] se [cnpj] não tiver 14 dígitos após strip.
  static String formatCnpj(String cnpj) {
    final s = stripCnpj(cnpj);
    if (s.length != 14) {
      throw ArgumentError.value(
        cnpj,
        'cnpj',
        'CNPJ inválido: deve ter 14 dígitos após remover a máscara.',
      );
    }
    return '${s.substring(0, 2)}.${s.substring(2, 5)}'
        '.${s.substring(5, 8)}/${s.substring(8, 12)}-${s.substring(12)}';
  }

  /// Gera um CNPJ numérico válido aleatório.
  ///
  /// Para CNPJs alfanuméricos (formato 2026), use
  /// `CnpjAlfanumerico.generate(forceAlphanumeric: true)`.
  ///
  /// - [formatted]: se `true`, retorna no padrão `'99.999.999/9999-99'`.
  static String generateCnpj({bool formatted = false}) {
    final rand = Random.secure();
    final d = List.generate(12, (_) => rand.nextInt(10));

    // Pesos do 1º DV: 5,4,3,2,9,8,7,6,5,4,3,2
    const w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += d[i] * w1[i];
    }
    final dv1 = sum % 11;
    d.add(dv1 < 2 ? 0 : 11 - dv1);

    // Pesos do 2º DV: 6,5,4,3,2,9,8,7,6,5,4,3,2
    const w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += d[i] * w2[i];
    }
    final dv2 = sum % 11;
    d.add(dv2 < 2 ? 0 : 11 - dv2);

    final cnpj = d.join();
    return formatted ? formatCnpj(cnpj) : cnpj;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CEP
  // ════════════════════════════════════════════════════════════════════════════

  /// Remove a máscara do CEP → apenas dígitos.
  static String stripCep(String cep) => cep.replaceAll(_nonDigit, '');

  /// Formata um CEP (8 dígitos) → `'99999-999'`.
  ///
  /// Lança [ArgumentError] se [cep] não tiver 8 dígitos após strip.
  static String formatCep(String cep) {
    final s = stripCep(cep);
    if (s.length != 8) {
      throw ArgumentError.value(
        cep,
        'cep',
        'CEP inválido: deve ter 8 dígitos após remover a máscara.',
      );
    }
    return '${s.substring(0, 5)}-${s.substring(5)}';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Telefone
  // ════════════════════════════════════════════════════════════════════════════

  /// Remove a máscara do telefone → apenas dígitos.
  static String stripPhone(String phone) => phone.replaceAll(_nonDigit, '');

  /// Extrai o DDD de um número com 10 ou 11 dígitos.
  ///
  /// Retorna os 2 primeiros dígitos, ou `''` se insuficientes.
  static String extractDdd(String phone) {
    final s = stripPhone(phone);
    return s.length >= 2 ? s.substring(0, 2) : '';
  }

  /// Formata um telefone com 10 ou 11 dígitos.
  ///
  /// - 10 dígitos → `'(99) 9999-9999'` (fixo)
  /// - 11 dígitos → `'(99) 99999-9999'` (celular)
  /// - [ddd] `false`: omite `(99)` e espaço.
  ///
  /// Lança [ArgumentError] se [phone] não tiver 10 ou 11 dígitos após strip.
  static String formatPhone(String phone, {bool ddd = true}) {
    final s = stripPhone(phone);

    if (s.length == 11) {
      return ddd
          ? '(${s.substring(0, 2)}) ${s.substring(2, 7)}-${s.substring(7)}'
          : '${s.substring(2, 7)}-${s.substring(7)}';
    }

    if (s.length == 10) {
      return ddd
          ? '(${s.substring(0, 2)}) ${s.substring(2, 6)}-${s.substring(6)}'
          : '${s.substring(2, 6)}-${s.substring(6)}';
    }

    throw ArgumentError.value(
      phone,
      'phone',
      'Telefone inválido: deve ter 10 ou 11 dígitos após remover a máscara.',
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // Moeda
  // ════════════════════════════════════════════════════════════════════════════

  /// Formata um [double] no padrão de moeda brasileira.
  ///
  /// - [symbol]: se `true` (padrão), prefixa com `'R$ '`.
  /// - [decimals]: número de casas decimais (padrão `2`).
  ///
  /// Exemplos:
  /// ```dart
  /// BrFormatter.formatCurrency(1234.5)                    // 'R$ 1.234,50'
  /// BrFormatter.formatCurrency(1234.5, symbol: false)     // '1.234,50'
  /// BrFormatter.formatCurrency(1234.5, decimals: 0)       // 'R$ 1.234'
  /// BrFormatter.formatCurrency(85437107.04)               // 'R$ 85.437.107,04'
  /// ```
  static String formatCurrency(
    double value, {
    bool symbol = true,
    int decimals = 2,
  }) {
    final raw = value.toStringAsFixed(decimals);
    final parts = raw.split('.');
    final intPart = parts[0];
    final decPart = decimals > 0 ? parts[1] : '';

    // Insere ponto de milhar na parte inteira
    final buf = StringBuffer();
    for (int i = 0, len = intPart.length; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }

    final result = decimals > 0 ? '${buf.toString()},$decPart' : buf.toString();
    return symbol ? 'R\$ $result' : result;
  }

  /// Remove o símbolo `'R$ '` de uma string monetária.
  ///
  /// Exemplo: `'R$ 1.234,56'` → `'1.234,56'`.
  static String stripCurrencySymbol(String value) =>
      value.replaceAll(_currencySymbol, '').trim();

  /// Converte uma string no formato `'R$ 1.234,56'` para [double].
  ///
  /// Funciona com ou sem o símbolo `R$`.
  ///
  /// Lança [FormatException] se a string não for convertível.
  static double parseCurrency(String value) {
    final stripped = value
        .replaceAll(_currencySymbol, '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.parse(stripped);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // KM
  // ════════════════════════════════════════════════════════════════════════════

  /// Formata um valor de quilometragem com separador de milhar.
  ///
  /// Exemplo: `BrFormatter.formatKm(85437)` → `'85.437 km'`.
  static String formatKm(int km) {
    final s = km.abs().toString();
    final buf = StringBuffer();
    for (int i = 0, len = s.length; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${km < 0 ? '-' : ''}${buf.toString()} km';
  }
}
