import 'locale/i_locale_br_zod.dart';
import 'locale/locale_pt_br.dart';
import 'models/br_zod_result.dart';
import 'validations/br.dart' as br;
import 'validations/generic.dart' as g;
import 'validations/security.dart' as sec;

export 'locale/i_locale_br_zod.dart';
export 'locale/locale_pt_br.dart';
export 'models/br_zod_result.dart';
export 'validations/security.dart' show PasswordPolicy;

/// Callback de validação: recebe o valor e retorna `null` (válido)
/// ou uma mensagem de erro (inválido).
typedef BrZodCallback = String? Function(dynamic value);

/// Validador fluente para Flutter/Dart com foco em validações brasileiras.
///
/// ## Uso básico
/// ```dart
/// TextFormField(
///   validator: BrZod().required().email().build,
/// )
/// ```
///
/// ## Locale customizado
/// ```dart
/// BrZod(locale: MyLocale()).required().cpf().build
///
/// // ou globalmente:
/// BrZod.defaultLocale = MyLocale();
/// ```
///
/// ## Validação de Map (APIs)
/// ```dart
/// final result = BrZod.validate(
///   data: {'email': 'foo', 'cpf': '111'},
///   params: {
///     'email': BrZod().required().email(),
///     'cpf':   BrZod().required().cpf(),
///   },
/// );
/// if (result.isNotValid) print(result.errors);
/// ```
class BrZod {
  /// Locale padrão aplicado quando nenhum locale é passado na instância.
  static ILocaleBrZod defaultLocale = const LocalePtBR();

  /// Locale desta instância. Se `null`, usa [defaultLocale].
  final ILocaleBrZod? locale;

  /// Lista interna de validadores encadeados.
  final List<BrZodCallback> _validations = [];

  ILocaleBrZod get _l => locale ?? defaultLocale;

  BrZod({this.locale});

  // ── Core ────────────────────────────────────────────────────

  /// Adiciona um validador à cadeia e retorna `this` para encadeamento.
  BrZod _add(BrZodCallback validator) {
    _validations.add(validator);
    return this;
  }

  /// Executa todos os validadores em ordem e retorna a primeira mensagem
  /// de erro encontrada, ou `null` se o valor for válido.
  ///
  /// Use diretamente como `validator:` no [TextFormField]:
  /// ```dart
  /// validator: BrZod().required().email().build,
  /// ```
  String? build(dynamic value) {
    for (final validate in _validations) {
      final result = validate(value);
      if (result == null) continue;
      if (result == _kOptionalSkip) return null; // optional short-circuit
      return result;
    }
    return null;
  }

  // ── Validações genéricas ────────────────────────────────────

  /// Campo obrigatório — rejeita `null` e string vazia.
  BrZod required([String? message]) => _add(
        (v) => g.isRequired(v) ? null : message ?? _l.required,
      );

  /// Campo opcional — se vazio/nulo, interrompe a cadeia sem erro.
  ///
  /// Coloque **antes** das demais validações:
  /// ```dart
  /// BrZod().optional().email().build // vazio = ok; preenchido = valida email
  /// ```
  BrZod optional() => _add(
        (v) => g.isEmpty(v) ? _kOptionalSkip : null,
      );

  /// Mínimo de [n] caracteres.
  BrZod min(int n, [String? message]) => _add(
        (v) => g.hasMinLength(v, n) ? null : message ?? _l.min(n),
      );

  /// Máximo de [n] caracteres.
  BrZod max(int n, [String? message]) => _add(
        (v) => g.hasMaxLength(v, n) ? null : message ?? _l.max(n),
      );

  /// Formato de e-mail válido.
  BrZod email([String? message]) => _add(
        (v) => g.isEmail(v) ? null : message ?? _l.email,
      );

  /// Telefone brasileiro válido (com ou sem DDD, celular ou fixo).
  BrZod phone([String? message]) => _add(
        (v) => g.isPhone(v) ? null : message ?? _l.phone,
      );

  /// Valor deve ser igual a [other].
  BrZod equals(dynamic other, [String? message]) => _add(
        (v) => g.isEquals(v, other) ? null : message ?? _l.equals,
      );

  /// Valor deve ser do tipo [T].
  ///
  /// Suporta `String`, `int`, `double`, `bool` e qualquer outro tipo via `is`.
  /// ```dart
  /// BrZod().required().type<int>().build
  /// ```
  BrZod type<T>([String? message]) => _add(
        (v) => g.isType<T>(v) ? null : message ?? _l.invalidType,
      );

  /// Validação customizada com função arbitrária.
  ///
  /// ```dart
  /// BrZod().custom((v) => v != 'admin', message: 'Nome reservado').build
  /// ```
  BrZod custom(
    bool Function(dynamic value) validate, {
    String? message,
  }) =>
      _add((v) => validate(v) ? null : message ?? _l.custom);

  /// Valor deve ser uma data válida.
  ///
  /// Aceita `dd/MM/yyyy`, `yyyy-MM-dd` e ISO 8601.
  BrZod isDate([String? message]) => _add(
        (v) => g.isDate(v) ? null : message ?? _l.invalidDate,
      );

  /// Data deve ser anterior a [max].
  BrZod isBefore(DateTime max, [String? message]) => _add(
        (v) => g.isBeforeDate(v, max) ? null : message ?? _l.maxDate(max),
      );

  /// Data deve ser posterior a [min].
  BrZod isAfter(DateTime min, [String? message]) => _add(
        (v) => g.isAfterDate(v, min) ? null : message ?? _l.minDate(min),
      );

  // ── Validações BR ───────────────────────────────────────────

  /// CPF válido (com ou sem máscara). Verifica dígitos verificadores.
  BrZod cpf([String? message]) => _add(
        (v) => br.isCpf(v) ? null : message ?? _l.cpf,
      );

  /// CNPJ numérico válido (com ou sem máscara).
  BrZod cnpj([String? message]) => _add(
        (v) => br.isCnpj(v) ? null : message ?? _l.cnpj,
      );

  /// CNPJ alfanumérico — IN RFB 2229/2024 (vigente a partir de julho/2026).
  ///
  /// Aceita letras A–Z nos primeiros 12 caracteres.
  /// Para validar tanto o formato antigo quanto o novo, use [cnpjOuAlfa].
  BrZod cnpjAlfa([String? message]) => _add(
        (v) => br.isCnpjAlfa(v) ? null : message ?? _l.cnpjAlfa,
      );

  /// CPF **ou** CNPJ numérico. Útil em campos de documento genérico.
  BrZod cpfOuCnpj([String? message]) => _add(
        (v) => br.isCpfOuCnpj(v) ? null : message ?? _l.cpfCnpj,
      );

  /// CEP brasileiro — formato `00000-000` ou `00000000`.
  BrZod cep([String? message]) => _add(
        (v) => br.isCep(v) ? null : message ?? _l.cep,
      );

  /// RG — formato mais comum (aceita com ou sem pontuação e dígito X).
  BrZod rg([String? message]) => _add(
        (v) => br.isRg(v) ? null : message ?? _l.rg,
      );

  /// Placa veicular — formato antigo (`ABC-1234`) e Mercosul (`ABC1D23`).
  BrZod placa([String? message]) => _add(
        (v) => br.isPlaca(v) ? null : message ?? _l.placa,
      );

  /// CNH — 11 dígitos com dois dígitos verificadores via módulo 11.
  BrZod cnh([String? message]) => _add(
        (v) => br.isCnh(v) ? null : message ?? _l.cnh,
      );

  /// RENAVAM — 9 ou 11 dígitos, módulo 11.
  BrZod renavam([String? message]) => _add(
        (v) => br.isRenavam(v) ? null : message ?? _l.renavam,
      );

  /// PIS/PASEP — 11 dígitos, módulo 11.
  BrZod pisPasep([String? message]) => _add(
        (v) => br.isPisPasep(v) ? null : message ?? _l.pisPasep,
      );

  /// Título de Eleitor — 12 dígitos, dois DVs via módulo 11.
  BrZod tituloEleitor([String? message]) => _add(
        (v) => br.isTituloEleitor(v) ? null : message ?? _l.tituloEleitor,
      );

  /// CNS (Cartão Nacional de Saúde) — 15 dígitos, algoritmo DATASUS.
  BrZod cns([String? message]) => _add(
        (v) => br.isCns(v) ? null : message ?? _l.cns,
      );

  // ── Validações de segurança ─────────────────────────────────

  /// Senha válida conforme política configurável.
  ///
  /// Padrão (`PasswordPolicy.strong`): 8+ caracteres, maiúscula, minúscula,
  /// número e símbolo especial.
  ///
  /// ```dart
  /// // Forte (padrão)
  /// BrZod().required().password().build
  ///
  /// // Média
  /// BrZod().required().password(policy: PasswordPolicy.medium).build
  ///
  /// // Customizada
  /// BrZod().required().password(policy: PasswordPolicy(minLength: 12)).build
  /// ```
  BrZod password({sec.PasswordPolicy policy = sec.PasswordPolicy.strong, String? message}) =>
      _add((v) => sec.isPassword(v, policy: policy) ? null : message ?? _l.password);

  /// UUID válido — qualquer versão por padrão. Versões: `'3'`, `'4'`, `'5'`, `'all'`.
  BrZod uuid({String version = 'all', String? message}) =>
      _add((v) => sec.isUuid(v, version: version) ? null : message ?? _l.uuid);

  /// URL válida com esquema `http`, `https` ou `ftp`.
  BrZod url([String? message]) =>
      _add((v) => sec.isUrl(v) ? null : message ?? _l.url);

  /// Endereço IPv4 válido (`0.0.0.0` a `255.255.255.255`).
  BrZod ipv4([String? message]) =>
      _add((v) => sec.isIpv4(v) ? null : message ?? _l.ipv4);

  /// Endereço IPv6 válido — formato completo ou comprimido.
  BrZod ipv6([String? message]) =>
      _add((v) => sec.isIpv6(v) ? null : message ?? _l.ipv6);

  /// Valor deve corresponder ao [pattern] regex fornecido.
  ///
  /// ```dart
  /// BrZod().required().regex(r'^\d{4}$', message: 'Apenas 4 dígitos').build
  /// ```
  BrZod regex(String pattern, {String? message}) =>
      _add((v) => sec.matchesRegex(v, pattern) ? null : message ?? _l.regex);

  // ── Validação de Map ────────────────────────────────────────

  /// Valida um [Map] de dados contra um [Map] de esquemas [BrZod].
  ///
  /// Suporta aninhamento:
  /// ```dart
  /// BrZod.validate(
  ///   data: {'user': {'email': 'x'}},
  ///   params: {'user': {'email': BrZod().email()}},
  /// );
  /// ```
  static BrZodResult validate({
    required Map<String, dynamic> data,
    required Map<String, dynamic> params,
  }) {
    final errors = _buildErrorMap(data: data, params: params);
    final errorList = _buildErrorList(data: data, params: params);
    return BrZodResult(
      isValid: errors.isEmpty,
      errors: errors,
      errorList: errorList,
    );
  }

  static Map<String, dynamic> _buildErrorMap({
    required Map<String, dynamic> data,
    required Map<String, dynamic> params,
  }) {
    final result = <String, dynamic>{};
    params.forEach((key, schema) {
      if (schema is BrZod) {
        final msg = schema.build(data[key] ?? '');
        if (msg != null) result[key] = msg;
      } else if (schema is Map<String, dynamic>) {
        final nested = _buildErrorMap(
          data: (data[key] as Map<String, dynamic>?) ?? {},
          params: schema,
        );
        if (nested.isNotEmpty) result[key] = nested;
      }
    });
    return result;
  }

  static List<String> _buildErrorList({
    required Map<String, dynamic> data,
    required Map<String, dynamic> params,
    String prefix = '',
  }) {
    final result = <String>[];
    params.forEach((key, schema) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (schema is BrZod) {
        final msg = schema.build(data[key] ?? '');
        if (msg != null) result.add('$fullKey: $msg');
      } else if (schema is Map<String, dynamic>) {
        result.addAll(_buildErrorList(
          data: (data[key] as Map<String, dynamic>?) ?? {},
          params: schema,
          prefix: fullKey,
        ));
      }
    });
    return result;
  }
}

/// Token interno usado pelo [BrZod.optional] para curto-circuitar a cadeia.
const String _kOptionalSkip = '__br_zod_optional_skip__';
