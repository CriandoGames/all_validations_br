import 'package:all_validations_br/br_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrLogLevel', () {
    test('índices em ordem crescente de severidade', () {
      expect(BrLogLevel.trace.index, lessThan(BrLogLevel.debug.index));
      expect(BrLogLevel.debug.index, lessThan(BrLogLevel.info.index));
      expect(BrLogLevel.info.index, lessThan(BrLogLevel.warning.index));
      expect(BrLogLevel.warning.index, lessThan(BrLogLevel.error.index));
      expect(BrLogLevel.error.index, lessThan(BrLogLevel.fatal.index));
    });

    test('labels têm 5 chars', () {
      for (final level in BrLogLevel.values) {
        expect(level.label.length, 5,
            reason: 'Label de $level deve ter 5 chars para alinhar colunas');
      }
    });

    test('cada nível tem código ANSI diferente', () {
      final codes = BrLogLevel.values.map((l) => l.ansiOpen).toSet();
      expect(codes.length, BrLogLevel.values.length,
          reason: 'Cada nível deve ter um código ANSI único');
    });
  });

  // ── BrLogFilter ───────────────────────────────────────────────────────────

  group('BrAllFilter', () {
    const filter = BrAllFilter();

    test('deixa passar todos os níveis', () {
      for (final level in BrLogLevel.values) {
        final record = _record(level);
        expect(filter.shouldLog(record), isTrue,
            reason: 'BrAllFilter deve aceitar $level');
      }
    });
  });

  group('BrNullFilter', () {
    const filter = BrNullFilter();

    test('bloqueia todos os níveis', () {
      for (final level in BrLogLevel.values) {
        final record = _record(level);
        expect(filter.shouldLog(record), isFalse,
            reason: 'BrNullFilter deve bloquear $level');
      }
    });
  });

  group('BrProductionFilter', () {
    test('padrão: aceita warning e acima', () {
      const filter = BrProductionFilter();
      expect(filter.shouldLog(_record(BrLogLevel.trace)), isFalse);
      expect(filter.shouldLog(_record(BrLogLevel.debug)), isFalse);
      expect(filter.shouldLog(_record(BrLogLevel.info)), isFalse);
      expect(filter.shouldLog(_record(BrLogLevel.warning)), isTrue);
      expect(filter.shouldLog(_record(BrLogLevel.error)), isTrue);
      expect(filter.shouldLog(_record(BrLogLevel.fatal)), isTrue);
    });

    test('minLevel customizado: error e acima', () {
      const filter = BrProductionFilter(minLevel: BrLogLevel.error);
      expect(filter.shouldLog(_record(BrLogLevel.warning)), isFalse);
      expect(filter.shouldLog(_record(BrLogLevel.error)), isTrue);
      expect(filter.shouldLog(_record(BrLogLevel.fatal)), isTrue);
    });
  });

  // ── BrSimplePrinter ───────────────────────────────────────────────────────

  group('BrSimplePrinter', () {
    const printer = BrSimplePrinter(showTag: true, showTime: false);

    test('retorna uma linha para mensagem simples', () {
      final record = _record(BrLogLevel.info, message: 'login ok', tag: 'Auth');
      final lines = printer.format(record);
      expect(lines.length, 1);
      expect(lines.first, contains('INFO'));
      expect(lines.first, contains('Auth'));
      expect(lines.first, contains('login ok'));
    });

    test('adiciona linha extra para error', () {
      final record = _record(
        BrLogLevel.error,
        message: 'falhou',
        error: Exception('timeout'),
      );
      final lines = printer.format(record);
      expect(lines.length, 2);
      expect(lines[1], contains('timeout'));
    });

    test('adiciona linha extra para stackTrace', () {
      final record = _record(
        BrLogLevel.error,
        message: 'crash',
        stackTrace: StackTrace.current,
      );
      final lines = printer.format(record);
      expect(lines.length, 2);
      expect(lines[1], contains('STACK'));
    });

    test('showTime inclui timestamp', () {
      const p = BrSimplePrinter(showTime: true);
      final lines = p.format(_record(BrLogLevel.debug, message: 'x'));
      // formato: YYYY-MM-DD HH:MM:SS.mmm
      expect(lines.first,
          matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}')));
    });
  });

  // ── BrPrettyPrinter ───────────────────────────────────────────────────────

  group('BrPrettyPrinter', () {
    const printer = BrPrettyPrinter(useColors: false);

    test('retorna ao menos 3 linhas (header + meta + footer)', () {
      final record = _record(BrLogLevel.info, message: 'ok');
      final lines = printer.format(record);
      expect(lines.length, greaterThanOrEqualTo(3));
    });

    test('header contém a tag', () {
      final record = _record(BrLogLevel.info, message: 'ok', tag: 'Checkout');
      final lines = printer.format(record);
      expect(lines.first, contains('Checkout'));
    });

    test('footer usa └', () {
      final record = _record(BrLogLevel.info, message: 'ok');
      final lines = printer.format(record);
      expect(lines.last, startsWith('└'));
    });

    test('inclui linhas de stack trace', () {
      final record = _record(
        BrLogLevel.error,
        message: 'crash',
        stackTrace: StackTrace.current,
      );
      final lines = printer.format(record);
      // deve ter mais linhas que o mínimo de 3
      expect(lines.length, greaterThan(4));
    });
  });

  // ── BrMemoryOutput ────────────────────────────────────────────────────────

  group('BrMemoryOutput', () {
    test('armazena registros', () {
      final memory = BrMemoryOutput();
      final logger = BrLogger(
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      logger.info('msg1');
      logger.warning('msg2');
      logger.error('msg3');

      expect(memory.records.length, 3);
      expect(memory.records[0].level, BrLogLevel.info);
      expect(memory.records[1].level, BrLogLevel.warning);
      expect(memory.records[2].level, BrLogLevel.error);
    });

    test('respeita maxRecords', () {
      final memory = BrMemoryOutput(maxRecords: 2);
      final logger = BrLogger(
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      logger.info('a');
      logger.info('b');
      logger.info('c'); // deve descartar 'a'

      expect(memory.records.length, 2);
      expect(memory.records[0].message, 'b');
      expect(memory.records[1].message, 'c');
    });

    test('clear() limpa tudo', () {
      final memory = BrMemoryOutput();
      final logger = BrLogger(
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      logger.info('x');
      memory.clear();

      expect(memory.records, isEmpty);
    });
  });

  // ── BrLogger (integração) ─────────────────────────────────────────────────

  group('BrLogger integração', () {
    test('todos os métodos geram registros com o nível correto', () {
      final memory = BrMemoryOutput();
      final log = BrLogger(
        tag: 'Test',
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      log.trace('t');
      log.debug('d');
      log.info('i');
      log.warning('w');
      log.error('e');
      log.fatal('f');

      final levels = memory.records.map((r) => r.level).toList();
      expect(levels, [
        BrLogLevel.trace,
        BrLogLevel.debug,
        BrLogLevel.info,
        BrLogLevel.warning,
        BrLogLevel.error,
        BrLogLevel.fatal,
      ]);
    });

    test('filter bloqueia registros abaixo do nível', () {
      final memory = BrMemoryOutput();
      final log = BrLogger(
        filter: const BrProductionFilter(minLevel: BrLogLevel.error),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      log.trace('ignorado');
      log.debug('ignorado');
      log.info('ignorado');
      log.warning('ignorado');
      log.error('gravado');
      log.fatal('gravado');

      expect(memory.records.length, 2);
    });

    test('tag é propagada para o record', () {
      final memory = BrMemoryOutput();
      final log = BrLogger(
        tag: 'ModuloX',
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      log.info('qualquer coisa');
      expect(memory.records.first.tag, 'ModuloX');
    });

    test('error e stackTrace são propagados', () {
      final memory = BrMemoryOutput();
      final log = BrLogger(
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: memory,
      );

      final ex = Exception('falhou');
      final st = StackTrace.current;
      log.error('ops', error: ex, stackTrace: st);

      final record = memory.records.first;
      expect(record.error, ex);
      expect(record.stackTrace, st);
    });

    test('BrMultiOutput entrega para todos os outputs', () {
      final mem1 = BrMemoryOutput();
      final mem2 = BrMemoryOutput();
      final log = BrLogger(
        filter: const BrAllFilter(),
        printer: const BrSimplePrinter(),
        output: BrMultiOutput([mem1, mem2]),
      );

      log.info('broadcast');

      expect(mem1.records.length, 1);
      expect(mem2.records.length, 1);
    });
  });
}

// ── helpers ───────────────────────────────────────────────────────────────────

BrLogRecord _record(
  BrLogLevel level, {
  Object? message = 'mensagem de teste',
  Object? error,
  StackTrace? stackTrace,
  String tag = 'Test',
}) {
  return BrLogRecord(
    level: level,
    message: message,
    tag: tag,
    time: DateTime.now(),
    error: error,
    stackTrace: stackTrace,
  );
}
