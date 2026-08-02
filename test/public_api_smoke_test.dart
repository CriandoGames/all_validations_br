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

  test('módulos do toolkit funcionam juntos pelo barrel principal', () {
    final maskedPhone = const PhoneMask().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '11912345678'),
    );
    expect(maskedPhone.text, '(11) 91234-5678');
    expect(BrZod().required().phone().build(maskedPhone.text), isNull);

    final cpfResult = AllValidations.isCpf('529.982.247-25')
        ? Result.success<String, String>('529.982.247-25')
        : Result.failure<String, String>('CPF inválido');
    expect(cpfResult.isSuccess, isTrue);

    final output = BrMemoryOutput(maxRecords: 1);
    final logger = BrLogger(
      tag: 'ToolkitTest',
      filter: const BrAllFilter(),
      output: output,
    );
    logger.info('fluxo validado');
    expect(output.records.single.message, 'fluxo validado');
    logger.dispose();

    final key = AllCrypto.generateKey();
    final envelope = AllCrypto.encryptText('segredo', key: key);
    expect(AllCrypto.decryptText(envelope, key: key), 'segredo');
    expect(envelope.toJson(), isNot(contains('key')));
  });
}
