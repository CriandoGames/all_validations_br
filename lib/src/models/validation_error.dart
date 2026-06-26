/// Representa um erro de validação pontual, com o campo e a mensagem.
///
/// Usado como tipo de [Failure] nos métodos `validate*()` de [AllValidations].
///
/// Exemplo:
/// ```dart
/// AllValidations.validateCPF(cpf).fold(
///   (err) => print('${err.property}: ${err.message}'),
///   (cpf) => print('CPF ok'),
/// );
/// ```
class ValidationError {
  final String property;
  final String message;

  const ValidationError({
    required this.property,
    required this.message,
  });

  @override
  String toString() =>
      'ValidationError(property: $property, message: $message)';

  @override
  bool operator ==(Object other) =>
      other is ValidationError &&
      other.property == property &&
      other.message == message;

  @override
  int get hashCode => Object.hash(property, message);
}
