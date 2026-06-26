import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para placa de veículo brasileira.
///
/// Aplica a máscara `XXX-XXXX` à medida que o usuário digita,
/// aceitando letras e dígitos (alfanumérico). Converte automaticamente
/// para maiúsculas.
///
/// Suporta ambos os formatos:
/// - **Antigo:** `ABC-1234` (3 letras + 4 dígitos)
/// - **Mercosul:** `ABC-1D23` (3 letras + 1 dígito + 1 letra + 2 dígitos)
///
/// Uso:
/// ```dart
/// TextField(
///   textCapitalization: TextCapitalization.characters,
///   inputFormatters: [PlacaMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'ABC1'`    → `'ABC-1'`
/// - `'ABC1234'` → `'ABC-1234'`  (formato antigo)
/// - `'ABC1D23'` → `'ABC-1D23'`  (Mercosul)
class PlacaMask extends BrInputMask {
  const PlacaMask();

  /// Número máximo de caracteres alfanuméricos de uma placa.
  static const int _maxChars = 7;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final chars = BrInputMask.alphanumeric(newValue.text);
    final buf = StringBuffer();
    final len = chars.length < _maxChars ? chars.length : _maxChars;
    for (int i = 0; i < len; i++) {
      if (i == 3) buf.write('-');
      buf.write(chars[i]);
    }
    return BrInputMask.collapsed(buf.toString());
  }
}
