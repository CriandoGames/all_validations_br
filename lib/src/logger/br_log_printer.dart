import 'br_log_level.dart';
import 'br_log_record.dart';

/// Transforma um [BrLogRecord] em uma lista de linhas para o output.
///
/// Retorne múltiplas linhas quando a mensagem precisar de mais de uma linha
/// (ex: pretty printer com header + body + stack trace).
abstract class BrLogPrinter {
  const BrLogPrinter();

  /// Formata [record] e retorna as linhas a serem escritas.
  List<String> format(BrLogRecord record);
}

// ── BrSimplePrinter ───────────────────────────────────────────────────────────

/// Printer minimalista — uma única linha, sem cores.
///
/// Formato: `[LEVEL] TAG: mensagem`
/// Com tempo: `2024-01-15 10:30:00.123 [LEVEL] TAG: mensagem`
///
/// Ideal para outputs que não suportam ANSI (ex: arquivos de log, servidores CI).
class BrSimplePrinter extends BrLogPrinter {
  final bool showTime;
  final bool showTag;

  const BrSimplePrinter({
    this.showTime = false,
    this.showTag = true,
  });

  @override
  List<String> format(BrLogRecord record) {
    final buffer = StringBuffer();

    if (showTime) {
      buffer.write(_formatTime(record.time));
      buffer.write(' ');
    }

    buffer.write('[${record.level.label.trim()}]');

    if (showTag && record.tag.isNotEmpty) {
      buffer.write(' ${record.tag}:');
    }

    buffer.write(' ${record.message}');

    final lines = <String>[buffer.toString()];

    if (record.error != null) {
      lines.add('  ERROR: ${record.error}');
    }

    if (record.stackTrace != null) {
      lines.add('  STACK:\n${record.stackTrace}');
    }

    return lines;
  }

  String _formatTime(DateTime t) => '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}.'
      '${t.millisecond.toString().padLeft(3, '0')}';
}

// ── BrPrettyPrinter ───────────────────────────────────────────────────────────

/// Printer colorido com caixas delimitadoras.
///
/// Exemplo de output (terminal com suporte ANSI):
/// ```
/// ┌─────────────── Auth ───────────────
/// │ [INFO ] 10:30:00.123
/// │ login bem-sucedido
/// └────────────────────────────────────
/// ```
class BrPrettyPrinter extends BrLogPrinter {
  /// Exibe o horário do evento.
  final bool showTime;

  /// Exibe a tag do logger.
  final bool showTag;

  /// Exibe as cores ANSI no terminal.
  final bool useColors;

  /// Número de linhas do stack trace a incluir (0 = todas).
  final int stackTraceMaxLines;

  static const _divider = '────────────────────────────────────';

  const BrPrettyPrinter({
    this.showTime = true,
    this.showTag = true,
    this.useColors = true,
    this.stackTraceMaxLines = 8,
  });

  @override
  List<String> format(BrLogRecord record) {
    final color = useColors ? record.level.ansiOpen : '';
    final reset = useColors ? BrLogLevelExt.ansiClose : '';

    final lines = <String>[];

    // ── header ───────────────────────────────────────────────────────────────
    final headerParts = <String>[];
    if (showTag && record.tag.isNotEmpty) headerParts.add(record.tag);
    final headerLabel =
        headerParts.isNotEmpty ? ' ${headerParts.join(' › ')} ' : '';
    lines.add('$color┌─$headerLabel$_divider$reset');

    // ── meta line (level + time) ──────────────────────────────────────────────
    final meta = StringBuffer('│ [${record.level.label}]');
    if (showTime) meta.write(' ${_formatTime(record.time)}');
    lines.add('$color$meta$reset');

    // ── message ───────────────────────────────────────────────────────────────
    final messageLines = record.message.toString().split('\n');
    for (final l in messageLines) {
      lines.add('$color│ $l$reset');
    }

    // ── error ─────────────────────────────────────────────────────────────────
    if (record.error != null) {
      lines.add('$color│$reset');
      lines.add('$color│ ⚠ ${record.error}$reset');
    }

    // ── stack trace ───────────────────────────────────────────────────────────
    if (record.stackTrace != null) {
      final stLines = record.stackTrace.toString().trimRight().split('\n');
      final limit = stackTraceMaxLines == 0
          ? stLines.length
          : stackTraceMaxLines.clamp(0, stLines.length);
      lines.add('$color│$reset');
      for (var i = 0; i < limit; i++) {
        lines.add('$color│ ${stLines[i]}$reset');
      }
      if (limit < stLines.length) {
        lines
            .add('$color│ … (${stLines.length - limit} linhas omitidas)$reset');
      }
    }

    // ── footer ────────────────────────────────────────────────────────────────
    lines.add('$color└$_divider──$reset');

    return lines;
  }

  String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}.'
      '${t.millisecond.toString().padLeft(3, '0')}';
}
