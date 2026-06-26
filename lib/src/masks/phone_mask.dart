import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para telefone brasileiro (fixo e celular).
///
/// Aplica máscara dinâmica conforme o número de dígitos digitados:
/// - **10 dígitos** (fixo): `(99) 9999-9999`
/// - **11 dígitos** (celular): `(99) 99999-9999`
///
/// O formato alterna automaticamente ao adicionar ou remover o 11º dígito.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.phone,
///   inputFormatters: [PhoneMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'11'`              → `'(11'`
/// - `'113'`             → `'(11) 3'`
/// - `'1133334444'`      → `'(11) 3333-4444'`
/// - `'11999998877'`     → `'(11) 99999-8877'`
class PhoneMask extends BrInputMask {
  const PhoneMask();

  static const int _maxMobile = 11;
  static const int _maxLandline = 10;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);

    // Decide o formato pelo tamanho atual: >10 dígitos → celular (11), senão fixo (10).
    final isMobile = d.length > _maxLandline;
    final maxDigits = isMobile ? _maxMobile : _maxLandline;
    // Índice do dígito após o qual entra o traço:
    // fixo → traço antes do índice 6; celular → antes do índice 7.
    final dashAt = isMobile ? 7 : 6;

    final buf = StringBuffer();
    final len = d.length < maxDigits ? d.length : maxDigits;

    for (int i = 0; i < len; i++) {
      if (i == 0) buf.write('(');
      if (i == 2) buf.write(') ');
      if (i == dashAt) buf.write('-');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
