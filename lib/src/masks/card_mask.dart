import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para número de cartão de crédito/débito.
///
/// Aplica a máscara `XXXX XXXX XXXX XXXX` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 16 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CardMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'4111'`             → `'4111'`
/// - `'41111'`            → `'4111 1'`
/// - `'4111111111111111'` → `'4111 1111 1111 1111'`
class CardMask extends BrInputMask {
  const CardMask();

  /// Comprimento máximo em dígitos de um número de cartão padrão.
  static const int _maxDigits = 16;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 4 || i == 8 || i == 12) buf.write(' ');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
