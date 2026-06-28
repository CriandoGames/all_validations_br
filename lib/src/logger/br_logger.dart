import 'br_log_filter.dart';
import 'br_log_level.dart';
import 'br_log_output.dart';
import 'br_log_printer.dart';
import 'br_log_record.dart';

/// Logger puro para Dart/Flutter — zero dependências externas.
///
/// Pipeline: `BrLogger` → `BrLogFilter` → `BrLogPrinter` → `BrLogOutput`
///
/// ## Uso básico
///
/// ```dart
/// final log = BrLogger(tag: 'Auth');
///
/// log.trace('iniciando handshake');
/// log.debug('userId: $id');
/// log.info('login bem-sucedido');
/// log.warning('token expira em 5 min');
/// log.error('falha na requisição', error: e, stackTrace: st);
/// log.fatal('banco de dados indisponível');
/// ```
///
/// ## Customizando
///
/// ```dart
/// final log = BrLogger(
///   tag: 'Pagamento',
///   filter: BrProductionFilter(),
///   printer: BrPrettyPrinter(showTime: true),
///   output: BrMultiOutput([BrDeveloperOutput(), BrMemoryOutput()]),
/// );
/// ```
class BrLogger {
  final String tag;
  final BrLogFilter filter;
  final BrLogPrinter printer;
  final BrLogOutput output;

  BrLogger({
    this.tag = '',
    BrLogFilter? filter,
    BrLogPrinter? printer,
    BrLogOutput? output,
  })  : filter = filter ?? const BrDevelopmentFilter(),
        printer = printer ?? const BrPrettyPrinter(),
        output = output ?? const BrPrintOutput() {
    this.output.init();
  }

  // ── Métodos de log ────────────────────────────────────────────────────────

  /// Rastreamento detalhado — mais verboso. Cor: cinza.
  void trace(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(BrLogLevel.trace, message, error: error, stackTrace: stackTrace);

  /// Informações de debug — útil durante desenvolvimento. Cor: azul.
  void debug(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(BrLogLevel.debug, message, error: error, stackTrace: stackTrace);

  /// Eventos normais do fluxo. Cor: verde.
  void info(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(BrLogLevel.info, message, error: error, stackTrace: stackTrace);

  /// Situações inesperadas não críticas. Cor: laranja.
  void warning(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(BrLogLevel.warning, message, error: error, stackTrace: stackTrace);

  /// Erros recuperáveis. Cor: vermelho.
  void error(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(BrLogLevel.error, message, error: error, stackTrace: stackTrace);

  /// Erros críticos — app não pode continuar. Cor: vermelho bold.
  void fatal(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(BrLogLevel.fatal, message, error: error, stackTrace: stackTrace);

  // ── Internals ─────────────────────────────────────────────────────────────

  void _log(
    BrLogLevel level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final record = BrLogRecord(
      level: level,
      message: message,
      tag: tag,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    if (!filter.shouldLog(record)) return;

    final lines = printer.format(record);
    output.write(record, lines);
  }

  /// Libera recursos do output (fecha arquivos, sockets, etc.).
  void dispose() => output.dispose();
}
