/// Módulo de validação fluente com foco em documentos brasileiros.
///
/// Zero dependências externas — implementado do zero, autocontido
/// e estruturado para eventual extração como pacote standalone.
///
/// ## Importação
///
/// ```dart
/// import 'package:all_validations_br/br_zod.dart';
/// ```
///
/// ## Uso básico em TextFormField
///
/// ```dart
/// TextFormField(
///   validator: BrZod().required().email().build,
/// )
/// ```
///
/// ## Documentos brasileiros
///
/// ```dart
/// BrZod().required().cpf().build
/// BrZod().required().cnpj().build
/// BrZod().optional().cep().build
/// ```
///
/// ## Validação de Map (APIs / Shelf)
///
/// ```dart
/// final result = BrZod.validate(
///   data: {'email': 'foo', 'cpf': '111'},
///   params: {
///     'email': BrZod().required().email(),
///     'cpf':   BrZod().required().cpf(),
///   },
/// );
/// if (result.isNotValid) print(result.errors);
/// ```
///
/// ## Locale customizado
///
/// ```dart
/// BrZod.defaultLocale = MyLocale(); // global
/// BrZod(locale: MyLocale()).required().cpf().build // por instância
/// ```
library br_zod;

export 'src/br_zod/br_zod.dart';
