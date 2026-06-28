import 'dart:developer' as developer;

import 'br_log_level.dart';
import 'br_log_record.dart';

/// Recebe as linhas formatadas pelo [BrLogPrinter] e as escreve no destino.
///
/// Implemente esta classe para criar outputs customizados (arquivo, rede, etc.).
abstract class BrLogOutput {
  const BrLogOutput();

  /// Inicialização opcional (abre arquivo, conecta socket, etc.).
  void init() {}

  /// Escreve [lines] no destino.
  void write(BrLogRecord record, List<String> lines);

  /// Limpeza opcional (fecha arquivo, etc.).
  void dispose() {}
}

// ── BrPrintOutput ─────────────────────────────────────────────────────────────

/// Escreve no console via `print()`.
///
/// Suporta cores ANSI quando o terminal as suporta.
/// Ideal para desenvolvimento local e scripts CLI.
class BrPrintOutput extends BrLogOutput {
  const BrPrintOutput();

  @override
  void write(BrLogRecord record, List<String> lines) {
    for (final line in lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}

// ── BrDeveloperOutput ─────────────────────────────────────────────────────────

/// Escreve via `dart:developer log()`.
///
/// Integra com o painel de Logs do Flutter DevTools.
/// Não suporta ANSI — use [BrSimplePrinter] como printer paired.
class BrDeveloperOutput extends BrLogOutput {
  const BrDeveloperOutput();

  @override
  void write(BrLogRecord record, List<String> lines) {
    final message = lines.join('\n');
    developer.log(
      message,
      name: record.tag,
      level: _dartLevel(record.level),
      error: record.error,
      stackTrace: record.stackTrace,
      time: record.time,
    );
  }

  /// Converte [BrLogLevel] para o nível numérico esperado por `dart:developer`.
  /// Segue a escala do package:logging (0–1200).
  int _dartLevel(BrLogLevel level) {
    switch (level) {
      case BrLogLevel.trace:
        return 300;
      case BrLogLevel.debug:
        return 500;
      case BrLogLevel.info:
        return 800;
      case BrLogLevel.warning:
        return 900;
      case BrLogLevel.error:
        return 1000;
      case BrLogLevel.fatal:
        return 1200;
    }
  }
}

// ── BrMemoryOutput ────────────────────────────────────────────────────────────

/// Mantém os eventos em memória — ideal para testes e inspeção em tempo real.
///
/// ```dart
/// final memory = BrMemoryOutput(maxRecords: 100);
/// final log = BrLogger(output: memory);
///
/// log.info('algo aconteceu');
///
/// expect(memory.records.last.level, BrLogLevel.info);
/// ```
class BrMemoryOutput extends BrLogOutput {
  final int maxRecords;
  final _records = <BrLogRecord>[];
  final _lines = <List<String>>[];

  BrMemoryOutput({this.maxRecords = 200});

  /// Todos os eventos armazenados (mais recente no final).
  List<BrLogRecord> get records => List.unmodifiable(_records);

  /// As linhas formatadas correspondentes a cada evento.
  List<List<String>> get lines => List.unmodifiable(_lines);

  @override
  void write(BrLogRecord record, List<String> lines) {
    if (_records.length >= maxRecords) {
      _records.removeAt(0);
      _lines.removeAt(0);
    }
    _records.add(record);
    _lines.add(List.unmodifiable(lines));
  }

  /// Limpa todos os registros armazenados.
  void clear() {
    _records.clear();
    _lines.clear();
  }
}

// ── BrMultiOutput ─────────────────────────────────────────────────────────────

/// Encaminha cada evento para múltiplos outputs simultaneamente.
///
/// ```dart
/// BrMultiOutput([
///   BrDeveloperOutput(),
///   BrMemoryOutput(),
/// ])
/// ```
class BrMultiOutput extends BrLogOutput {
  final List<BrLogOutput> outputs;

  BrMultiOutput(this.outputs);

  @override
  void init() {
    for (final o in outputs) {
      o.init();
    }
  }

  @override
  void write(BrLogRecord record, List<String> lines) {
    for (final o in outputs) {
      o.write(record, lines);
    }
  }

  @override
  void dispose() {
    for (final o in outputs) {
      o.dispose();
    }
  }
}
