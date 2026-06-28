import 'i_locale_br_zod.dart';

/// Locale padrão do [BrZod] em Português do Brasil.
class LocalePtBR implements ILocaleBrZod {
  const LocalePtBR();

  // ── Genéricas ──────────────────────────────────────────────
  @override
  String get required => 'Campo obrigatório';

  @override
  String get email => 'E-mail inválido';

  @override
  String get phone => 'Telefone inválido';

  @override
  String get equals => 'Os valores não coincidem';

  @override
  String get custom => 'Valor inválido';

  @override
  String get optional => 'Campo opcional inválido';

  @override
  String get invalidDate => 'Data inválida';

  @override
  String get invalidType => 'Tipo inválido';

  @override
  String min(int n) => 'Mínimo de $n caracteres';

  @override
  String max(int n) => 'Máximo de $n caracteres';

  @override
  String minDate(DateTime date) => 'Data deve ser após ${_fmt(date)}';

  @override
  String maxDate(DateTime date) => 'Data deve ser antes de ${_fmt(date)}';

  // ── Segurança ───────────────────────────────────────────────
  @override
  String get password =>
      'Senha deve ter ao menos 8 caracteres, maiúscula, minúscula, número e símbolo';

  @override
  String get uuid => 'UUID inválido';

  @override
  String get url => 'URL inválida';

  @override
  String get ipv4 => 'Endereço IPv4 inválido';

  @override
  String get ipv6 => 'Endereço IPv6 inválido';

  @override
  String get regex => 'Formato inválido';

  // ── Documentos BR ──────────────────────────────────────────
  @override
  String get cpf => 'CPF inválido';

  @override
  String get cnpj => 'CNPJ inválido';

  @override
  String get cnpjAlfa => 'CNPJ Alfanumérico inválido';

  @override
  String get cpfCnpj => 'CPF ou CNPJ inválido';

  @override
  String get cep => 'CEP inválido';

  @override
  String get rg => 'RG inválido';

  @override
  String get placa => 'Placa veicular inválida';

  @override
  String get cnh => 'CNH inválida';

  @override
  String get renavam => 'RENAVAM inválido';

  @override
  String get pisPasep => 'PIS/PASEP inválido';

  @override
  String get tituloEleitor => 'Título de eleitor inválido';

  @override
  String get cns => 'Cartão Nacional de Saúde inválido';

  // ── Helpers ────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
