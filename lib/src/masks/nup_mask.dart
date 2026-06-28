import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para NUP (Número Único de Protocolo do governo federal).
///
/// Aplica a máscara `1234567-89.0123.4.56.7890` (20 dígitos):
/// - 7 dígitos + `-`
/// - 2 dígitos + `.`
/// - 4 dígitos + `.`
/// - 1 dígito  + `.`
/// - 2 dígitos + `.`
/// - 4 dígitos
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [const NupMask()],
/// )
/// ```
///
/// Exemplo completo:
/// - `'12345678901234567890'` → `'1234567-89.0123.4.56.7890'`
class NupMask extends BrInputMask {
  const NupMask();

  static const int _maxDigits = 20;

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
      if (i == 7) buf.write('-');
      if (i == 9 || i == 13 || i == 14 || i == 16) buf.write('.');
      buf.write(d[i]);
    }
    return BrInputMask.collapsed(buf.toString());
  }
}
