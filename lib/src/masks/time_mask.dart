import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para hora no formato `HH:MM`.
///
/// Aplica a máscara `99:99` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 4 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [TimeMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'14'`   → `'14'`
/// - `'143'`  → `'14:3'`
/// - `'1430'` → `'14:30'`
class TimeMask extends BrInputMask {
  const TimeMask();

  /// Comprimento máximo em dígitos: 2 (hora) + 2 (minuto).
  static const int _maxDigits = 4;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 2) buf.write(':');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
