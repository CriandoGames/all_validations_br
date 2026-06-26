import 'package:flutter/services.dart';
import 'br_input_mask.dart';

/// Formatter de campo para CNPJ numérico.
///
/// Aplica a máscara `99.999.999/9999-99` à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 14 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CnpjMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'11'`               → `'11'`
/// - `'11222'`            → `'11.222'`
/// - `'11222333'`         → `'11.222.333'`
/// - `'112223330001'`     → `'11.222.333/0001'`
/// - `'11222333000181'`   → `'11.222.333/0001-81'`
class CnpjMask extends BrInputMask {
  const CnpjMask();

  /// Comprimento máximo em dígitos de um CNPJ numérico.
  static const int _maxDigits = 14;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    final buf = StringBuffer();

    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (i == 2 || i == 5) buf.write('.');
      if (i == 8) buf.write('/');
      if (i == 12) buf.write('-');
      buf.write(d[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
