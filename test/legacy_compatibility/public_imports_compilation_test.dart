import 'package:all_validations_br/all_validations_br.dart' as aggregate;
import 'package:all_validations_br/br_logger.dart' as logger;
import 'package:all_validations_br/br_zod.dart' as zod;
import 'package:all_validations_br/crypt.dart' as crypt;
import 'package:all_validations_br/regions_validations.dart' as regions;
import 'package:all_validations_br/validation.dart' as validation;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todos os imports públicos históricos compilam', () {
    expect(aggregate.AllValidations.isCpf('52998224725'), isTrue);
    expect(const aggregate.CpfMask(), isA<aggregate.BrInputMask>());
    expect(aggregate.HelperUtil.countWords('um dois'), 2);

    expect(zod.BrZod().required().cpf().build('52998224725'), isNull);
    expect(validation.Contract().isTrue(true, 'ok', 'erro').isValid, isTrue);
    expect(regions.BrazilianState.SP.name, 'SP');

    final memory = logger.BrMemoryOutput();
    final log = logger.BrLogger(
      output: memory,
      filter: const logger.BrAllFilter(),
      printer: const logger.BrSimplePrinter(),
    );
    log.info('compatibilidade');
    expect(memory.records.single.message, 'compatibilidade');

    expect(crypt.CryptAlgorithm.values, isNotEmpty);
    final result = aggregate.Result.success<String, int>(1);
    expect(result.successValue, 1);
  });
}
