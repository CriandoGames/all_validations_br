import 'dart:math';

/// Suporte ao CNPJ alfanumérico — Receita Federal, IN RFB 2229/2024.
///
/// A partir de julho de 2026 o CNPJ passa a aceitar letras maiúsculas (A–Z)
/// nos 12 primeiros caracteres, mantendo os 2 dígitos verificadores numéricos.
///
/// Formato com máscara: `AA.BBB.CCC/DDDD-VV`
///
/// ### Bug corrigido em relação ao brasil_fields
/// O brasil_fields usa `codeUnits.first - 48` para converter todos os caracteres,
/// o que produz valores errados para letras (A → 17 em vez de 10, Z → 42 em vez
/// de 35). A conversão correta da IN RFB 2229/2024 é:
/// - Dígitos `'0'–'9'` → valores 0–9 (`codeUnit - 48`)
/// - Letras  `'A'–'Z'` → valores 10–35 (`codeUnit - 55`)
class CnpjAlfanumerico {
  CnpjAlfanumerico._();

  static final RegExp _stripRegex = RegExp(r'[^A-Z0-9]');
  static final RegExp _dvRegex = RegExp(r'^\d{2}$');
  static final RegExp _allSameRegex = RegExp(r'^(.)\1{13}$');

  /// Todos os caracteres válidos nos primeiros 12 posições: 0–9 seguido de A–Z.
  static final List<String> validChars = List.generate(10, (i) => '$i') +
      List.generate(26, (i) => String.fromCharCode(i + 65));

  // ── Conversão de caractere → valor numérico ──────────────────────────────

  /// Converte um code unit para seu valor posicional no conjunto [0-9A-Z].
  ///
  /// `'0'`–`'9'` (codes 48–57) → 0–9
  /// `'A'`–`'Z'` (codes 65–90) → 10–35
  static int _charValue(int codeUnit) {
    if (codeUnit >= 48 && codeUnit <= 57) return codeUnit - 48;
    return codeUnit - 55;
  }

  // ── Dígito verificador ───────────────────────────────────────────────────

  /// Calcula um dígito verificador sobre [body] usando módulo 11 com
  /// pesos 2–9 aplicados da direita para a esquerda (ciclo reinicia em 2
  /// após atingir 9).
  static int _calcDigit(String body) {
    int weight = 2;
    int sum = 0;

    for (int i = body.length - 1; i >= 0; i--) {
      sum += _charValue(body.codeUnitAt(i)) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }

    final mod = sum % 11;
    return mod < 2 ? 0 : 11 - mod;
  }

  // ── API pública ──────────────────────────────────────────────────────────

  /// Remove a máscara do CNPJ, preservando apenas `[A-Z0-9]`.
  ///
  /// A entrada é convertida para maiúsculas antes do strip.
  static String strip(String cnpj) =>
      cnpj.toUpperCase().replaceAll(_stripRegex, '');

  /// Valida um CNPJ numérico ou alfanumérico (com ou sem máscara).
  ///
  /// Retorna `false` para:
  /// - strings nulas/vazias
  /// - comprimento ≠ 14 após strip
  /// - sequências repetidas (`00000000000000`, etc.)
  /// - dígitos verificadores inválidos
  /// - dígitos verificadores não numéricos (posições 12–13)
  static bool isValid(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) return false;

    final s = strip(cnpj);

    if (s.length != 14) return false;

    // Rejeita sequências com 14 caracteres iguais
    if (_allSameRegex.hasMatch(s)) return false;

    // Os dois últimos caracteres devem ser dígitos (DV é sempre numérico)
    if (!_dvRegex.hasMatch(s.substring(12))) return false;

    final dv1 = _calcDigit(s.substring(0, 12));
    if (dv1 != int.parse(s[12])) return false;

    final dv2 = _calcDigit(s.substring(0, 13));
    if (dv2 != int.parse(s[13])) return false;

    return true;
  }

  /// Formata um CNPJ (com ou sem máscara) no padrão `AA.BBB.CCC/DDDD-VV`.
  ///
  /// Lança [ArgumentError] se [cnpj] não tiver 14 caracteres após o strip.
  static String format(String cnpj) {
    final s = strip(cnpj);
    if (s.length != 14) {
      throw ArgumentError.value(
        cnpj,
        'cnpj',
        'CNPJ inválido: deve ter 14 caracteres após remover a máscara.',
      );
    }
    return '${s.substring(0, 2)}.${s.substring(2, 5)}.${s.substring(5, 8)}'
        '/${s.substring(8, 12)}-${s.substring(12)}';
  }

  /// Gera um CNPJ alfanumérico válido aleatório.
  ///
  /// - [formatted]: se `true`, retorna com máscara `AA.BBB.CCC/DDDD-VV`.
  /// - [forceAlphanumeric]: se `true`, garante ao menos uma letra nos 12
  ///   primeiros caracteres (distingue do CNPJ puramente numérico legado).
  static String generate({
    bool formatted = false,
    bool forceAlphanumeric = false,
  }) {
    final rand = Random.secure();
    String body;

    do {
      body = List.generate(
        12,
        (_) => validChars[rand.nextInt(validChars.length)],
      ).join();
    } while (forceAlphanumeric && RegExp(r'^\d+$').hasMatch(body));

    final dv1 = _calcDigit(body);
    final dv2 = _calcDigit('$body$dv1');
    final cnpj = '$body$dv1$dv2';

    return formatted ? format(cnpj) : cnpj;
  }
}
