/// Interface de mensagens de erro do [BrZod].
///
/// Implemente esta interface para criar um locale customizado:
/// ```dart
/// class MyLocale implements ILocaleBrZod {
///   @override
///   String get required => 'Campo obrigatório';
///   // ...
/// }
///
/// BrZod(locale: MyLocale()).required().email().build
/// ```
abstract interface class ILocaleBrZod {
  // ── Genéricas ──────────────────────────────────────────────
  String get required;
  String get email;
  String get phone;
  String get equals;
  String get custom;
  String get optional;
  String get invalidDate;
  String get invalidType;

  String min(int n);
  String max(int n);
  String minDate(DateTime date);
  String maxDate(DateTime date);

  // ── Segurança ───────────────────────────────────────────────
  String get password;
  String get uuid;
  String get url;
  String get ipv4;
  String get ipv6;
  String get regex;

  // ── Documentos BR ──────────────────────────────────────────
  String get cpf;
  String get cnpj;
  String get cnpjAlfa;
  String get cpfCnpj;
  String get cep;
  String get rg;
  String get placa;
  String get cnh;
  String get renavam;
  String get pisPasep;
  String get tituloEleitor;
  String get cns;
}
