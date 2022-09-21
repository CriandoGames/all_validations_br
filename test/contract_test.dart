import 'package:all_validations_br/validation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestParameters extends FluntNotifiable {
  final String name;
  final String email;

  TestParameters({
    required this.name,
    required this.email,
  }) {
    addNotifications(Contract()
        .hasMinLen(name, 2, 'TestParameters.Name',
            "Nome deve ter no mínimo 2 caracteres!")
        .isEmail(email, "TestParameters.Email", "Email deve ser preenchido!"));
  }
}

main() {
  group("Contract Validation Test", () {
    test("should be return Error validation name invalid ", () {
      final testParameters =
          TestParameters(email: "exemplo@teste.com", name: "c");

      // print(testParameters.notifications.length);

      expect(testParameters.notifications.length, 1);
      expect(testParameters.isValid, false);

      //print
      testParameters.notifications.forEach((f) => print(f.message));
    });
  });
}
