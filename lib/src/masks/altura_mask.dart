import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para altura em metros com 2 casas decimais.
///
/// Aplica a máscara `X,XX` à medida que o usuário digita (esquerda para
/// direita), aceitando apenas dígitos e limitando a 3 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [AlturaMask()],
///   decoration: InputDecoration(suffixText: 'm'),
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'1'`   → `'1'`
/// - `'17'`  → `'1,7'`
/// - `'175'` → `'1,75'`
/// - `'222'` → `'2,22'`
class AlturaMask extends BrInputMask {
  const AlturaMask();

  static const int _maxDigits = 3;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final raw = d.length < _maxDigits ? d : d.substring(0, _maxDigits);
    if (raw.length == 1) return BrInputMask.collapsed(raw);

    return BrInputMask.collapsed('${raw[0]},${raw.substring(1)}');
  }
}
