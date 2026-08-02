import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o barrel principal expõe símbolos característicos do agregador', () {
    expect(AllValidations.isCpf('529.982.247-25'), isTrue);
    expect(Result.success<String, int>(42).successValue, 42);
    expect(HelperUtil.countWords('dois termos'), 2);
    expect(const CpfMask(), isA<CpfMask>());
  });
}
