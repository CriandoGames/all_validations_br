import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para valores monetários em centavos, sem prefixo `R$`.
///
/// Funciona como a [CurrencyMask], porém exibe apenas o número formatado
/// — útil quando o símbolo de moeda já aparece na UI como label ou sufixo.
///
/// A entrada é feita da direita para a esquerda (abordagem centavos):
/// digitar `1` exibe `0,01`; digitar `100` exibe `1,00`.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CentavosMask()],
///   decoration: InputDecoration(prefixText: 'R\$ '),
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'1'`       → `'0,01'`
/// - `'7194'`    → `'71,94'`
/// - `'1234567'` → `'12.345,67'`
class CentavosMask extends BrInputMask {
  const CentavosMask();

  static const int _maxDigits = 13;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final raw = d.length > _maxDigits ? d.substring(d.length - _maxDigits) : d;
    final padded = raw.padLeft(3, '0');
    final intPart = padded.substring(0, padded.length - 2);
    final decPart = padded.substring(padded.length - 2);
    final intClean = intPart.replaceFirst(RegExp(r'^0+'), '');
    final intFinal = intClean.isEmpty ? '0' : intClean;

    return BrInputMask.collapsed('${_addThousands(intFinal)},$decPart');
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
