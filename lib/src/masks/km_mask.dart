import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para quilometragem.
///
/// Aplica separador de milhar (`.`) à medida que o usuário digita,
/// aceitando apenas dígitos e limitando a 7 caracteres numéricos
/// (até `9.999.999` km).
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [KmMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'999'`     → `'999'`
/// - `'1000'`    → `'1.000'`
/// - `'999999'`  → `'999.999'`
/// - `'9999999'` → `'9.999.999'`
class KmMask extends BrInputMask {
  const KmMask();

  /// Número máximo de dígitos (suporta até 9.999.999 km).
  static const int _maxDigits = 7;

  static final RegExp _leadingZeros = RegExp(r'^0+');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final raw = d.length > _maxDigits ? d.substring(0, _maxDigits) : d;
    final clean = raw.replaceFirst(_leadingZeros, '');
    final n = clean.isEmpty ? '0' : clean;

    return BrInputMask.collapsed(_addThousands(n));
  }

  static String _addThousands(String n) {
    if (n.length <= 3) return n;
    final buf = StringBuffer();
    final start = n.length % 3;
    if (start > 0) buf.write(n.substring(0, start));
    for (int i = start; i < n.length; i += 3) {
      if (buf.isNotEmpty) buf.write('.');
      buf.write(n.substring(i, i + 3));
    }
    return buf.toString();
  }
}
