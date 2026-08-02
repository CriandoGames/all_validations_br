// ignore_for_file: deprecated_member_use_from_same_package

import 'package:all_validations_br/br_zod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o barrel histórico de BrZod preserva sua superfície estreita', () {
    final BrZodCallback validator = BrZod().required().cpf().build;
    const ILocaleBrZod locale = LocalePtBR();
    const policy = PasswordPolicy.strong;
    const mapResult = BrZodResult(
      isValid: true,
      errors: {},
      errorList: [],
    );

    expect(validator('529.982.247-25'), isNull);
    expect(validator('111.111.111-11'), isNotNull);
    expect(locale.required, isNotEmpty);
    expect(policy.minLength, 8);
    expect(mapResult.isValid, isTrue);
  });
}
