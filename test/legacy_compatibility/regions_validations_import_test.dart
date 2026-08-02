// ignore_for_file: deprecated_member_use_from_same_package

import 'package:all_validations_br/regions_validations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o barrel histórico geográfico preserva modelos característicos', () {
    expect(AllValidationsGetMonth.listMonths, hasLength(12));
    expect(AllValidationsGetWeek.listDaysWeek, isNotEmpty);
    expect(AllValidationsGetRegions.listRegions, contains('Sudeste'));
    expect(AllValidationsGetStates.listStates, contains('São Paulo'));
    expect(BrazilianState.SP.name, 'SP');
  });
}
