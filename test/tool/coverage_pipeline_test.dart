import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage_pipeline.dart';

void main() {
  late Directory packageDirectory;

  setUp(() {
    packageDirectory = Directory.systemTemp.createTempSync(
      'all_validations_br_coverage_',
    );
  });

  tearDown(() {
    if (packageDirectory.existsSync()) {
      packageDirectory.deleteSync(recursive: true);
    }
  });

  test('remove relatório antigo antes de executar os testes', () {
    final coverage = Directory(
      '${packageDirectory.path}${Platform.pathSeparator}coverage',
    )..createSync();
    File('${coverage.path}${Platform.pathSeparator}lcov.info')
        .writeAsStringSync('LF:1\nLH:1\n');

    resetCoverage(packageDirectory);

    expect(coverage.existsSync(), isFalse);
  });

  test('falha imediatamente e identifica o pacote sem LCOV', () {
    expect(
      () => readLcovTotals('all_result', packageDirectory),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          allOf(contains('all_result'), contains('lcov.info')),
        ),
      ),
    );
  });

  test('aceita LCOV válido e soma os totais', () {
    final coverage = Directory(
      '${packageDirectory.path}${Platform.pathSeparator}coverage',
    )..createSync();
    File('${coverage.path}${Platform.pathSeparator}lcov.info')
        .writeAsStringSync('LF:10\nLH:7\nLF:5\nLH:4\n');

    final totals = readLcovTotals('package', packageDirectory);

    expect(totals.found, 15);
    expect(totals.hit, 11);
  });
}
