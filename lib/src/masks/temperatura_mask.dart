import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para temperatura com 1 casa decimal.
///
/// Aplica a máscara `XX,X` à medida que o usuário digita (esquerda para
/// direita), aceitando apenas dígitos e limitando a 3 caracteres numéricos.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [TemperaturaMask()],
///   decoration: InputDecoration(suffixText: '°C'),
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'36'`  → `'36'`
/// - `'365'` → `'36,5'` (temperatura corporal)
/// - `'271'` → `'27,1'`
/// - `'000'` → `'00,0'`
class TemperaturaMask extends BrInputMask {
  const TemperaturaMask();

  static const int _maxDigits = 3;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final raw = d.length < _maxDigits ? d : d.substring(0, _maxDigits);
    if (raw.length < _maxDigits) return BrInputMask.collapsed(raw);

    return BrInputMask.collapsed('${raw.substring(0, 2)},${raw[2]}');
  }
}
