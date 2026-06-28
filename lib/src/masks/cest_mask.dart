import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para o código CEST (Código Especificador da
/// Substituição Tributária).
///
/// Aplica a máscara `12.345.67` (7 dígitos): dois grupos separados por `.`.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [const CestMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'12'`      → `'12'`
/// - `'123'`     → `'12.3'`
/// - `'12345'`   → `'12.345'`
/// - `'1234567'` → `'12.345.67'`
class CestMask extends BrInputMask {
  const CestMask();

  static const int _maxDigits = 7;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final buf = StringBuffer();
    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 2 || i == 5) buf.write('.');
      buf.write(d[i]);
    }
    return BrInputMask.collapsed(buf.toString());
  }
}
