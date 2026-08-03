import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('agregador expõe versões corrigidas', () {
    expect(
      AllValidations.isBrazilianCellPhone('11@99999#8877'),
      isFalse,
    );

    expect(
      () => Contract().isGreaterThan(
        '10',
        2,
        'value',
        'Tipos incompatíveis',
      ),
      returnsNormally,
    );

    expect(
      () => BrMemoryOutput(maxRecords: 0),
      throwsArgumentError,
    );

    expect(
      AllValidations.validatePixKey('12.345.678/0001-95').successValue,
      PixKeyType.cnpj,
    );

    expect(
      AllValidations.validatePixKey('12ABC34501DE35').successValue,
      PixKeyType.cnpj,
    );

    expect(BrZod().type<int>().build(123), isNull);
    expect(BrZod().type<int>().build('123'), isNotNull);
  });
}
