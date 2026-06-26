import 'package:flutter/services.dart';
import 'br_input_mask.dart';

/// Formatter de campo para CNPJ alfanumérico (formato 2026).
///
/// Aplica a estrutura de máscara `XX.XXX.XXX/XXXX-XX` aceitando letras
/// maiúsculas (`A–Z`) e dígitos (`0–9`) nas 14 posições do CNPJ.
/// Letras minúsculas são convertidas automaticamente para maiúsculas.
///
/// > **Nota:** A receita federal exige que os dois dígitos verificadores
/// > (posições 13–14) sejam sempre numéricos. A validação do conteúdo deve
/// > ser feita separadamente via [CnpjAlfanumerico.isValid].
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.text,
///   textCapitalization: TextCapitalization.characters,
///   inputFormatters: [CnpjAlfaMask()],
/// )
/// ```
///
/// Exemplos de transformação:
/// - `'AB'`                   → `'AB'`
/// - `'AB123'`                → `'AB.123'`
/// - `'AB123CDE'`             → `'AB.123.CDE'`
/// - `'AB123CDE0001'`         → `'AB.123.CDE/0001'`
/// - `'AB123CDE000139'`       → `'AB.123.CDE/0001-39'`
class CnpjAlfaMask extends BrInputMask {
  const CnpjAlfaMask();

  /// Comprimento máximo em caracteres `[A-Z0-9]` de um CNPJ alfanumérico.
  static const int _maxChars = 14;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final chars = BrInputMask.alphanumeric(newValue.text);
    final buf = StringBuffer();

    final len = chars.length < _maxChars ? chars.length : _maxChars;
    for (int i = 0; i < len; i++) {
      if (i == 2 || i == 5) buf.write('.');
      if (i == 8) buf.write('/');
      if (i == 12) buf.write('-');
      buf.write(chars[i]);
    }

    return BrInputMask.collapsed(buf.toString());
  }
}
