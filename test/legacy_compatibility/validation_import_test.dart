// ignore_for_file: deprecated_member_use_from_same_package

import 'package:all_validations_br/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o barrel histórico de contratos preserva contratos e avisos', () {
    final contract = Contract().isEmail(
      'invalido',
      'email',
      'E-mail inválido',
    );

    expect(contract, isA<ContractValidations>());
    expect(contract.notifications, hasLength(1));
    expect(contract.notifications.single, isA<ValidationNotification>());
    expect(ValidationNotifiable(), isA<ValidationNotifiable>());
  });
}
