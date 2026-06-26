import 'package:flutter/services.dart';
import 'br_input_mask.dart';

/// Formatter de campo para CEP brasileiro.
///
/// Aplica a máscara `99999-999` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 8 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CepMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'01310'`    → `'01310'`
/// - `'013101'`   → `'01310-1'`
/// - `'01310100'` → `'01310-100'`
class CepMask extends BrInputMask {
  const CepMask();

  /// Comprimento máximo em dígitos de um CEP.
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
      if (i == 5) buf.write('-');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
