import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para Cartão Nacional de Saúde (CNS).
///
/// Aplica a máscara `111 2222 3333 4444` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 15 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CnsMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'111'`             → `'111'`
/// - `'1112'`            → `'111 2'`
/// - `'1112222'`         → `'111 2222'`
/// - `'111222233334444'` → `'111 2222 3333 4444'`
class CnsMask extends BrInputMask {
  const CnsMask();

  static const int _maxDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 3 || i == 7 || i == 11) buf.write(' ');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
