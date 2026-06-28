import 'br_log_level.dart';

/// Representa um evento de log imutável.
///
/// Criado internamente pelo [BrLogger] e passado para o pipeline
/// filter → printer → output.
final class BrLogRecord {
  /// Severidade do evento.
  final BrLogLevel level;

  /// Mensagem principal. Pode ser uma [String] ou um objeto qualquer —
  /// o printer chama `.toString()` na hora de formatar.
  final Object? message;

  /// Erro/exceção associado (opcional).
  final Object? error;

  /// Stack trace associado ao [error] (opcional).
  final StackTrace? stackTrace;

  /// Tag do logger que gerou o evento (normalmente o nome do módulo/classe).
  final String tag;

  /// Instante em que o evento foi criado.
  final DateTime time;

  const BrLogRecord({
    required this.level,
    required this.message,
    required this.tag,
    required this.time,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() =>
      'BrLogRecord(level: $level, tag: $tag, message: $message)';
}
