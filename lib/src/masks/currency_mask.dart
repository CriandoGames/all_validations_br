import 'package:flutter/services.dart';

import 'br_input_mask.dart';

/// Formatter de campo para moeda brasileira (Real).
///
/// Aplica formatação em tempo real com a abordagem **centavos da direita
/// para a esquerda**: os dígitos digitados preenchem o valor sempre a
/// partir dos centavos, crescendo para a esquerda.
///
/// O campo sempre exibe o prefixo `R$ ` e as casas decimais separadas por
/// vírgula, com pontos de milhar inseridos automaticamente.
///
/// Uso:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [CurrencyMask()],
/// )
/// ```
///
/// Exemplos de transformação progressiva:
/// | Dígitos digitados | Resultado       |
/// |-------------------|-----------------|
/// | `'1'`             | `'R$ 0,01'`     |
/// | `'12'`            | `'R$ 0,12'`     |
/// | `'123'`           | `'R$ 1,23'`     |
/// | `'1234'`          | `'R$ 12,34'`    |
/// | `'123456'`        | `'R$ 1.234,56'` |
/// | `'12345678'`      | `'R$ 123.456,78'`|
class CurrencyMask extends BrInputMask {
  const CurrencyMask();

  /// Limite de dígitos para evitar overflow: R$ 99.999.999.999,99 = 13 dígitos.
  static const int _maxDigits = 13;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = BrInputMask.digits(newValue.text);
    if (d.isEmpty) return BrInputMask.collapsed('');

    // Mantém apenas os últimos _maxDigits dígitos para evitar overflow.
    final raw = d.length > _maxDigits ? d.substring(d.length - _maxDigits) : d;

    // Garante ao menos 3 dígitos para separar 2 casas decimais.
    final padded = raw.padLeft(3, '0');

    // Separa parte inteira e decimal.
    final intPart = padded.substring(0, padded.length - 2);
    final decPart = padded.substring(padded.length - 2);

    // Remove zeros à esquerda da parte inteira (mantendo ao menos '0').
    final intRaw = intPart.replaceFirst(RegExp(r'^0+'), '');
    final intClean = intRaw.isEmpty ? '0' : intRaw;

    return BrInputMask.collapsed('R\$ ${_addThousands(intClean)},$decPart');
  }

  /// Insere pontos de milhar em [n] (somente dígitos, sem zeros à esquerda).
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
