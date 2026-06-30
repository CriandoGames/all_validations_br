import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para data de expiração — suporta dois formatos de forma
/// dinâmica com base na quantidade de dígitos digitados:
///
/// - `MM/AA`   — até 4 dígitos: `'12/24'`
/// - `MM/AAAA` — a partir do 5° dígito: `'12/2024'`
///
/// Use este formatter quando o campo aceitar tanto ano com 2 quanto com 4
/// dígitos (ex: documentos, passaportes, CNH).
///
/// Para campos de cartão de crédito/débito — que seguem obrigatoriamente o
/// formato `MM/AA` — prefira [CardExpiryMask], que trunca em 4 dígitos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [ExpiryMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'1224'`   → `'12/24'`   (MM/AA)
/// - `'122024'` → `'12/2024'` (MM/AAAA)
/// - `'122'`    → `'12/2'`    (digitação parcial)
/// - `'12245'`  → `'12/245'`  (trunca ao 6° dígito)
class ExpiryMask extends BrInputMask {
  const ExpiryMask();

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
