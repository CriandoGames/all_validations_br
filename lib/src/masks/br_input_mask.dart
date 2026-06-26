import 'package:flutter/services.dart';

/// Classe base abstrata para todos os formatters de campo (máscaras) da biblioteca.
///
/// Estende [TextInputFormatter] do Flutter. As subclasses aplicam máscaras
/// específicas para CPF, CNPJ, CEP, telefone, data, moeda, cartão, etc.
///
/// ## Vantagens sobre implementações ad-hoc
/// - **RegExps cacheadas** como `static final` — compiladas uma única vez.
/// - **Helpers comuns** (`digits`, `collapsed`) disponíveis para todas as subclasses.
/// - **`const` constructors** nas subclasses — zero custo de instanciação.
///
/// ## Exemplo de uso
/// ```dart
/// TextField(
///   inputFormatters: [CpfMask()],
/// )
/// ```
abstract class BrInputMask extends TextInputFormatter {
  const BrInputMask();

  // ── RegExps compartilhados ─────────────────────────────────────────────────

  /// Remove qualquer caractere que não seja dígito.
  static final RegExp _nonDigit = RegExp(r'\D');

  /// Remove qualquer caractere que não seja letra maiúscula ou dígito.
  static final RegExp _nonAlphanumeric = RegExp(r'[^A-Z0-9]');

  // ── Utilitários protegidos ─────────────────────────────────────────────────

  /// Retorna apenas os dígitos de [value].
  static String digits(String value) => value.replaceAll(_nonDigit, '');

  /// Retorna apenas os caracteres `[A-Z0-9]` de [value] (maiúsculas).
  static String alphanumeric(String value) =>
      value.toUpperCase().replaceAll(_nonAlphanumeric, '');

  /// Constrói um [TextEditingValue] com [text] e cursor colapsado no final.
  ///
  /// Use este helper no final de [formatEditUpdate] para garantir que o
  /// cursor sempre fique após o último caractere digitado.
  static TextEditingValue collapsed(String text) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
}
