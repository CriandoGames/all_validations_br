// ignore_for_file: deprecated_member_use_from_same_package

import 'package:all_validations_br/br_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o barrel histórico de logger preserva o pipeline público', () {
    final output = BrMemoryOutput();
    final logger = BrLogger(
      tag: 'compat',
      filter: const BrAllFilter(),
      printer: const BrSimplePrinter(),
      output: output,
    );
    addTearDown(logger.dispose);

    logger.info('ok');

    expect(output.records.single.level, BrLogLevel.info);
  });
}
