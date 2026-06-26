import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para data de validade de cartão.
///
/// Aplica a máscara `MM/AA` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 4 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CardExpiryMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'12'`   → `'12'`
/// - `'123'`  → `'12/3'`
/// - `'1224'` → `'12/24'`
class CardExpiryMask extends BrInputMask {
  const CardExpiryMask();

  /// Comprimento máximo em dígitos: 2 (mês) + 2 (ano).
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
      if (i == 2) buf.write('/');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
