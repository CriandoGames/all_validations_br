/// Módulo de validação por contrato — validação acumulativa de entidades de domínio.
///
/// Exporta `Contract`, `ValidationNotifiable` e `ContractValidations`
/// para construir entidades que acumulam múltiplos erros antes de decidir
/// se são válidas.
///
/// ## Importação
///
/// ```dart
/// import 'package:all_validations_br/validation.dart';
/// ```
///
/// ## Uso básico
///
/// ```dart
/// class CadastroParams extends ValidationNotifiable {
///   CadastroParams({required String nome, required String email}) {
///     addNotifications(
///       Contract()
///         .hasMinLen(nome, 2, 'nome', 'Mínimo 2 caracteres')
///         .isEmail(email, 'email', 'E-mail inválido'),
///     );
///   }
/// }
///
/// final params = CadastroParams(nome: 'J', email: 'ruim');
/// if (params.isNotValid) {
///   params.notifications.forEach((n) => print(n.message));
/// }
/// ```
///
/// > Para validação de campos de formulário Flutter, prefira o módulo fluente:
/// > `import 'package:all_validations_br/br_zod.dart';`
library contract_validation;

export './src/notifications/notifiable.dart';
export './src/validator/contract.dart';
export './src/validator/contract_validations.dart';
