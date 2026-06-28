import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para Certidão de Nascimento brasileira.
///
/// Aplica a máscara `000000 11 22 3333 4 55555 666 7777777 88` (32 dígitos),
/// onde os grupos são separados por espaços:
/// - 6 dígitos (livro) + espaço
/// - 2 dígitos (folha) + espaço
/// - 2 dígitos (termo) + espaço
/// - 4 dígitos + espaço
/// - 1 dígito  + espaço
/// - 5 dígitos + espaço
/// - 3 dígitos + espaço
/// - 7 dígitos + espaço
/// - 2 dígitos
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [const CertNascimentoMask()],
/// )
/// ```
///
/// Exemplo completo (32 dígitos):
/// `'00000011223333455555666777777788'`
/// → `'000000 11 22 3333 4 55555 666 7777777 88'`
class CertNascimentoMask extends BrInputMask {
  const CertNascimentoMask();

  static const int _maxDigits = 32;

  // Índices do dígito ANTES do qual deve ser inserido um espaço.
  static const Set<int> _spacesBefore = {6, 8, 10, 14, 15, 20, 23, 30};

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    final buf = StringBuffer();
    final len = d.length < _maxDigits ? d.length : _maxDigits;
    for (int i = 0; i < len; i++) {
      if (_spacesBefore.contains(i)) buf.write(' ');
      buf.write(d[i]);
    }
    return BrInputMask.collapsed(buf.toString());
  }
}
