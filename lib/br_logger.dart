/// Biblioteca de compatibilidade para o pipeline de logging [BrLogger].
///
/// Novos projetos devem importar `package:all_logger/all_logger.dart`.
/// O import histórico continua mantido e não tem versão de remoção aprovada.
///
/// ```dart
/// import 'package:all_validations_br/br_logger.dart';
///
/// final log = BrLogger(tag: 'Auth');
/// log.info('login concluído');
/// log.dispose();
/// ```
@Deprecated('Use package:all_logger/all_logger.dart.')
library br_logger;

export 'package:all_logger/all_logger.dart';
