import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para CPF.
///
/// Aplica a máscara `999.999.999-99` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 11 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CpfMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'1'`           → `'1'`
/// - `'1234'`        → `'123.4'`
/// - `'12345678901'` → `'123.456.789-01'`
class CpfMask extends BrInputMask {
  const CpfMask();

  /// Comprimento máximo em dígitos de um CPF.
  static const int _maxDigits = 11;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 3 || i == 6) buf.write('.');
      if (i == 9) buf.write('-');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
