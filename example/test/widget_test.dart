import 'package:all_observer/all_observer.dart';
import 'package:all_validations_br_example/main.dart';
import 'package:flutter/foundation.dart' show ValueKey;
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ObserverConfig.strictMode = true;
  });

  tearDown(ObserverConfig.reset);

  testWidgets('aplicativo integrado inicia', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('AllLogger — pipeline testável'), findsOneWidget);
    expect(
      find.textContaining('Sucesso: CPF', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('All Validations BR — Exemplos'), findsOneWidget);
    expect(find.text('AllValidations — CPF'), findsOneWidget);
  });

  testWidgets('interface reage à mutação observável', (tester) async {
    final controller = ExamplesController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(MyApp(controller: controller));
    expect(find.byKey(const ValueKey('crypt-error')), findsNothing);

    controller.cryptError.value = 'Falha demonstrativa';
    await tester.pump();

    expect(find.byKey(const ValueKey('crypt-error')), findsOneWidget);
    expect(find.text('Falha demonstrativa'), findsOneWidget);
    expect(controller.hasError.value, isTrue);
  });

  testWidgets('logger integrado registra evento em memória', (tester) async {
    final controller = ExamplesController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(MyApp(controller: controller));
    await tester.tap(find.text('Registrar evento seguro'));
    await tester.pump();

    expect(controller.logOutput.records, hasLength(1));
    expect(find.textContaining('[ToolkitExample]'), findsOneWidget);
  });
}
