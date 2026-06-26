import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para data de validade de cartão.
///
/// Suporta dois formatos de forma dinâmica:
/// - `MM/AA` — até 4 dígitos: `'12/24'`
/// - `MM/AAAA` — a partir do 5° dígito: `'12/2024'`
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
/// - `'1224'`   → `'12/24'`   (MM/AA)
/// - `'122024'` → `'12/2024'` (MM/AAAA)
class CardExpiryMask extends BrInputMask {
  const CardExpiryMask();

  static const int _maxShort = 4; // MM/AA
  static const int _maxLong = 6; // MM/AAAA

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final maxDigits = d.length > _maxShort ? _maxLong : _maxShort;
    final buf = StringBuffer();

    final len = d.length < maxDigits ? d.length : maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 2) buf.write('/');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
