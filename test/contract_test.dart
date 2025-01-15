import 'package:all_validations_br/validation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestParameters extends ValidationNotifiable {
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
  late ContractValidations contract;

  setUp(() {
    contract = ContractValidations();
  });

  test('isStrongPassword', () {
    contract.isStrongPassword("Strong@123", "password", "Senha fraca");
    contract.isStrongPassword("another", "password", "Senha fraca");
    contract.isStrongPassword("weak", "password", "Senha fraca");

    expect(contract.notifications.length, 2);
  });

  test('isURL', () {
    contract.isURL("https://example.com", "url", "URL inválida");
    contract.isURL("ftp://example.com", "url", "URL inválida");
    contract.isURL("invalid_url", "url", "URL inválida");

    expect(contract.notifications.length, 1);
  });

  test('isPhoneNumber', () {
    contract.isPhoneNumber("+55 11 91234-5678", "phone", "Número inválido");
    contract.isPhoneNumber("(11) 2345-6789", "phone", "Número inválido");
    contract.isPhoneNumber("12345", "phone", "Número inválido");

    expect(contract.notifications.length, 1);
  });

  test('isValidBRZip', () {
    contract.isValidBRZip("12345-678", "zip", "CEP inválido");
    contract.isValidBRZip("12345678", "zip", "CEP inválido");
    contract.isValidBRZip("1234", "zip", "CEP inválido");

    expect(contract.notifications.length, 1);
  });

  test('isUUID', () {
    contract.isUUID(
        "550e8400-e29b-41d4-a716-446655440000", "uuid", "UUID inválido");
    contract.isUUID(
        "123e4567-e89b-12d3-a456-426614174000", "uuid", "UUID inválido");
    contract.isUUID("invalid-uuid", "uuid", "UUID inválido");

    expect(contract.notifications.length, 1);
  });

  test('isPalindrome', () {
    contract.isPalindrome("ana", "palindrome", "Não é palíndromo");
    contract.isPalindrome(
        "A man, a plan, a canal: Panama", "palindrome", "Não é palíndromo");
    contract.isPalindrome("hello", "palindrome", "Não é palíndromo");

    expect(contract.notifications.length, 1);
  });

  test('customValidation', () {
    contract.customValidation(() => true, "custom", "Falha na validação");
    contract.customValidation(() => true, "custom", "Falha na validação");
    contract.customValidation(() => false, "custom", "Falha na validação");

    expect(contract.notifications.length, 1);
  });

  test('isEnum', () {
    contract.isEnum("SP", ["SP", "RJ", "MG"], "enum", "Valor inválido");
    contract.isEnum("RJ", ["SP", "RJ", "MG"], "enum", "Valor inválido");
    contract.isEnum("XX", ["SP", "RJ", "MG"], "enum", "Valor inválido");

    expect(contract.notifications.length, 1);
  });

  test('isBefore', () {
    contract.isBefore(
        DateTime(2023, 1, 1), DateTime(2024, 1, 1), "date", "Data inválida");
    contract.isBefore(
        DateTime(2022, 1, 1), DateTime(2023, 1, 1), "date", "Data inválida");
    contract.isBefore(
        DateTime(2025, 1, 1), DateTime(2024, 1, 1), "date", "Data inválida");

    expect(contract.notifications.length, 1);
  });

  test('isUnique', () {
    contract.isUnique("A", ["B", "C", "D"], "unique", "Valor não é único");
    contract.isUnique("E", ["F", "G", "H"], "unique", "Valor não é único");
    contract.isUnique("A", ["A", "B", "C"], "unique", "Valor não é único");

    expect(contract.notifications.length, 1);
  });

  test('isNullOrNullable', () {
    contract.isNullOrNullable(null, "value", "Valor não pode ser nulo");
    contract.isNullOrNullable(5, "value", "Valor não pode ser nulo");

    expect(contract.notifications.length, 1); // Ambos são válidos
  });

  test('isNotNullOrEmpty', () {
    contract.isNotNullOrEmpty("texto", "value", "Texto não pode ser vazio");
    contract.isNotNullOrEmpty("", "value", "Texto não pode ser vazio");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('isNullOrEmpty', () {
    contract.isNullOrEmpty("", "value", "Texto deve estar vazio");
    contract.isNullOrEmpty("texto", "value", "Texto deve estar vazio");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('hasMinLen', () {
    contract.hasMinLen("12345", 3, "value", "Texto muito curto");
    contract.hasMinLen("12", 3, "value", "Texto muito curto");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('hasMaxLen', () {
    contract.hasMaxLen("123", 5, "value", "Texto muito longo");
    contract.hasMaxLen("123456", 5, "value", "Texto muito longo");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('hasLen', () {
    contract.hasLen("12345", 5, "value", "Tamanho incorreto");
    contract.hasLen("123", 5, "value", "Tamanho incorreto");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('contains', () {
    contract.contains("hello world", "world", "value", "Não contém o texto");
    contract.contains("hello world", "test", "value", "Não contém o texto");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('isDigit', () {
    contract.isDigit("12345", "value", "Não é número");
    contract.isDigit("abc", "value", "Não é número");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('hasMinLengthIfNotNullOrEmpty', () {
    contract.hasMinLengthIfNotNullOrEmpty(
        "texto", 3, "value", "Texto curto demais");
    contract.hasMinLengthIfNotNullOrEmpty("", 3, "value", "Texto curto demais");

    expect(contract.notifications.length, 0); // Ambos são válidos
  });

  test('hasMaxLengthIfNotNullOrEmpty', () {
    contract.hasMaxLengthIfNotNullOrEmpty(
        "texto", 10, "value", "Texto longo demais");
    contract.hasMaxLengthIfNotNullOrEmpty(
        "texto muito longo", 10, "value", "Texto longo demais");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('hasExactLengthIfNotNullOrEmpty', () {
    contract.hasExactLengthIfNotNullOrEmpty(
        "12345", 5, "value", "Tamanho incorreto");
    contract.hasExactLengthIfNotNullOrEmpty(
        "123", 5, "value", "Tamanho incorreto");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('isEmail', () {
    contract.isEmail("email@example.com", "email", "E-mail inválido");
    contract.isEmail("email_invalido", "email", "E-mail inválido");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('isValidCPF', () {
    contract.isValidCPF("123.456.789-09", "cpf", "CPF inválido");
    contract.isValidCPF("000.000.000-00", "cpf", "CPF inválido");

    expect(contract.notifications.length, 1); // Um falha
  });

  test('isValidCNPJ', () {
    contract.isValidCNPJ("12.345.678/0001-95", "cnpj", "CNPJ inválido");
    contract.isValidCNPJ("00.000.000/0000-00", "cnpj", "CNPJ inválido");

    expect(contract.notifications.length, 1); // Um falha
  });
}
