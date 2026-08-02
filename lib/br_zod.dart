/// Biblioteca de compatibilidade para a validação fluente [BrZod].
///
/// Novos projetos devem importar o barrel estreito do pacote especializado:
/// `package:all_br_validations/br_zod.dart`.
///
/// O import histórico continua mantido e preserva `BrZod`, seu callback,
/// locale, resultado de mapas e política de senha, exatamente como o barrel
/// original. Não há versão de remoção aprovada.
///
/// ```dart
/// import 'package:all_validations_br/br_zod.dart';
///
/// final validator = BrZod().required().cpf().build;
/// ```
@Deprecated('Use package:all_br_validations/br_zod.dart.')
library br_zod;

export 'package:all_br_validations/br_zod.dart';
