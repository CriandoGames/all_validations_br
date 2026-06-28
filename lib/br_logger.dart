/// Módulo de logging puro para Dart/Flutter.
///
/// Zero dependências — usa apenas `dart:core` e `dart:developer`.
/// Funciona em projetos Flutter e Dart server-side.
///
/// ## Importação
///
/// ```dart
/// import 'package:all_validations_br/br_logger.dart';
/// ```
///
/// ## Exemplo rápido
///
/// ```dart
/// final log = BrLogger(tag: 'Auth');
///
/// log.trace('iniciando handshake');
/// log.debug('userId: $id');
/// log.info('login bem-sucedido');
/// log.warning('token expira em 5 min');
/// log.error('falha', error: e, stackTrace: st);
/// log.fatal('banco indisponível');
/// ```
library br_logger;

export 'src/logger/br_log_filter.dart';
export 'src/logger/br_log_level.dart';
export 'src/logger/br_log_output.dart';
export 'src/logger/br_log_printer.dart';
export 'src/logger/br_log_record.dart';
export 'src/logger/br_logger.dart';
