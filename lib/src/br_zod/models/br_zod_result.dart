/// Resultado de [BrZod.validate] — usado na validação de Maps.
class BrZodResult {
  /// `true` quando todos os campos são válidos.
  final bool isValid;

  /// `true` quando ao menos um campo é inválido.
  bool get isNotValid => !isValid;

  /// Mapa de erros: chave → mensagem (pode ser aninhado para objetos).
  final Map<String, dynamic> errors;

  /// Lista plana de erros no formato `"campo: mensagem"`.
  final List<String> errorList;

  const BrZodResult({
    required this.isValid,
    required this.errors,
    required this.errorList,
  });

  @override
  String toString() => 'BrZodResult(isValid: $isValid, errors: $errors)';
}
