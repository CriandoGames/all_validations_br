import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para peso com 1 casa decimal.
///
/// Aplica a máscara `XXX,X` à medida que o usuário digita (esquerda para
/// direita), aceitando apenas dígitos e limitando a 4 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [PesoMask()],
///   decoration: InputDecoration(suffixText: 'kg'),
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'70'`   → `'70'`
/// - `'705'`  → `'705'`
/// - `'7051'` → `'705,1'`
/// - `'9999'` → `'999,9'`
class PesoMask extends BrInputMask {
  const PesoMask();

  static const int _maxDigits = 4;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final raw = d.length < _maxDigits ? d : d.substring(0, _maxDigits);
    if (raw.length < _maxDigits) return BrInputMask.collapsed(raw);

    return BrInputMask.collapsed('${raw.substring(0, 3)},${raw[3]}');
  }
}
