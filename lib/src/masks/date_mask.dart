import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para data brasileira.
///
/// Aplica a máscara `99/99/9999` (DD/MM/AAAA) à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 8 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [DateMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'01'`         → `'01'`
/// - `'011'`        → `'01/1'`
/// - `'0107'`       → `'01/07'`
/// - `'01072'`      → `'01/07/2'`
/// - `'01072026'`   → `'01/07/2026'`
class DateMask extends BrInputMask {
  const DateMask();

  /// Comprimento máximo em dígitos: 2 (dia) + 2 (mês) + 4 (ano).
  static const int _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
