import '../notifications/notifiable.dart';
import 'result.dart';

/// Alias de domínio: resultado de uma validação que carrega [T] em caso de
/// sucesso ou uma lista de [ValidationNotification] em caso de falha.
///
/// É o tipo retornado por `Contract.toResult<T>(value)`.
///
/// ```dart
/// ValidationResult<UserDto> result = Contract()
///   .requires()
///   .isCPF(cpf, 'cpf', 'CPF inválido')
///   .isEmail(email, 'email', 'Email inválido')
///   .toResult(UserDto(cpf: cpf, email: email));
///
/// result.fold(
///   (errors) => showErrors(errors),   // List<ValidationNotification>
///   (user)   => createUser(user),     // UserDto
/// );
/// ```
typedef ValidationResult<T> = Result<List<ValidationNotification>, T>;
