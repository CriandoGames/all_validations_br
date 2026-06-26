import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo que alterna automaticamente entre CPF e CNPJ.
///
/// - Até 11 dígitos → aplica máscara CPF (`999.999.999-99`)
/// - A partir do 12° dígito → aplica máscara CNPJ (`99.999.999/9999-99`)
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CpfOuCnpjMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'12345678901'`   → `'123.456.789-01'` (CPF)
/// - `'123456789012'`  → `'12.345.678/9012'` (CNPJ parcial)
/// - `'11222333000181'` → `'11.222.333/0001-81'` (CNPJ completo)
class CpfOuCnpjMask extends BrInputMask {
  const CpfOuCnpjMask();

  static const int _maxCpf = 11;
  static const int _maxCnpj = 14;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.length > _maxCpf) return _formatAsCnpj(d);
    return _formatAsCpf(d);
  }

  static TextEditingValue _formatAsCpf(String d) {
    final buf = StringBuffer();
    final len = d.length < _maxCpf ? d.length : _maxCpf;
    for (int i = 0; i < len; i++) {
      if (i == 3 || i == 6) buf.write('.');
      if (i == 9) buf.write('-');
      buf.write(d[i]);
    }
    return BrInputMask.collapsed(buf.toString());
  }

  static TextEditingValue _formatAsCnpj(String d) {
    final buf = StringBuffer();
    final len = d.length < _maxCnpj ? d.length : _maxCnpj;
    for (int i = 0; i < len; i++) {
      if (i == 2 || i == 5) buf.write('.');
      if (i == 8) buf.write('/');
      if (i == 12) buf.write('-');
      buf.write(d[i]);
    }
    return BrInputMask.collapsed(buf.toString());
  }
}
