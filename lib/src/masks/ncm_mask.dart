import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para código NCM (Nomenclatura Comum do Mercosul).
///
/// Aplica a máscara `1234.56.78` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 8 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [NcmMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'1234'`     → `'1234'`
/// - `'12345'`    → `'1234.5'`
/// - `'123456'`   → `'1234.56'`
/// - `'12345678'` → `'1234.56.78'`
class NcmMask extends BrInputMask {
  const NcmMask();

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
      if (i == 4 || i == 6) buf.write('.');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
