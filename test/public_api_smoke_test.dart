import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('APIs públicas principais permanecem disponíveis', () {
    expect(AllValidations.isCpf('52998224725'), isTrue);
    expect(AllValidations.getStateByDDD('11'), BrazilianState.SP);
    expect(AllValidations.isCreditCard('4111111111111111'), isTrue);

    expect(
      Contract().isTrue(true, 'value', 'erro').isValid,
      isTrue,
    );

    expect(
      BrZod().required().email().build('user@example.com'),
      isNull,
    );

    expect(
      CnpjAlfanumerico.isValid('12ABC34501DE35'),
      isTrue,
    );
  });
}
