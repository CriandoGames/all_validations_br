import 'package:all_validations_br/all_validations_br.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('Month', () {
    test('should be return list of month at Brazil', () {
      expect(AllValidationsGetMonth.listMonths, [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro'
      ]);
    });

    test('should be return month at Brazil', () {
      expect(AllValidationsGetMonth.mapMonths['Janeiro'], 1);
      expect(AllValidationsGetMonth.mapMonths['Fevereiro'], 2);
      expect(AllValidationsGetMonth.mapMonths['Março'], 3);
      expect(AllValidationsGetMonth.mapMonths['Abril'], 4);
      expect(AllValidationsGetMonth.mapMonths['Maio'], 5);
      expect(AllValidationsGetMonth.mapMonths['Junho'], 6);
      expect(AllValidationsGetMonth.mapMonths['Julho'], 7);
      expect(AllValidationsGetMonth.mapMonths['Agosto'], 8);
      expect(AllValidationsGetMonth.mapMonths['Setembro'], 9);
      expect(AllValidationsGetMonth.mapMonths['Outubro'], 10);
      expect(AllValidationsGetMonth.mapMonths['Novembro'], 11);
      expect(AllValidationsGetMonth.mapMonths['Dezembro'], 12);
    });
  });

  group('weeks', () {
    test('should be return list of weeks at Brazil', () {
      expect(AllValidationsGetWeek.listDaysWeekAbvr, [
        'Segunda',
        'Terça',
        'Quarta',
        'Quinta',
        'Sexta',
        'Sábado',
        'Domingo'
      ]);
    });

    test('should be return week at Brazil', () {
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Domingo'], 1);
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Segunda'], 2);
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Terça'], 3);
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Quarta'], 4);
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Quinta'], 5);
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Sexta'], 6);
      expect(AllValidationsGetWeek.mapDaysWeekOrderAbvr['Sábado'], 7);
    });
  });
}
