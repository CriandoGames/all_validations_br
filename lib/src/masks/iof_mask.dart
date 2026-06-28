import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para alíquota de IOF (Imposto sobre Operações
/// Financeiras) com 6 casas decimais.
///
/// Aplica a máscara `X,XXXXXX` (1 dígito inteiro + 6 decimais = 7 dígitos
/// máximo), entrada esquerda para direita.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [const IofMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'1'`       → `'1'`
/// - `'12'`      → `'1,2'`
/// - `'1234567'` → `'1,234567'`
/// - `'0038000'` → `'0,038000'`
class IofMask extends BrInputMask {
  const IofMask();

  static const int _maxDigits = 7;

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
