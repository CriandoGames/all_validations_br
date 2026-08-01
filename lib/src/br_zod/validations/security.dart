/// Funções puras de validação de segurança usadas pelo [BrZod].
///
/// Separadas da classe principal para facilitar testes unitários
/// e eventual extração do módulo como pacote standalone.
library;

import '../../validator/internal/url_validator.dart';

// ── Senha ────────────────────────────────────────────────────

/// Configuração de política de senha para [isPassword].
class PasswordPolicy {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumber;
  final bool requireSpecial;

  const PasswordPolicy({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumber = true,
    this.requireSpecial = true,
  });

  /// Política fraca: apenas comprimento mínimo de 6.
  static const weak = PasswordPolicy(
    minLength: 6,
    requireUppercase: false,
    requireLowercase: false,
    requireNumber: false,
    requireSpecial: false,
  );

  /// Política média: maiúscula + minúscula + número, mínimo 6.
  static const medium = PasswordPolicy(
    minLength: 6,
    requireUppercase: true,
    requireLowercase: true,
    requireNumber: true,
    requireSpecial: false,
  );

  /// Política forte (padrão): todos os requisitos, mínimo 8.
  static const strong = PasswordPolicy();
}

/// Valida senha conforme [policy] (padrão: forte — 8+ chars, maiúscula,
/// minúscula, número e símbolo).
bool isPassword(dynamic value,
    {PasswordPolicy policy = PasswordPolicy.strong}) {
  final s = value?.toString() ?? '';
  if (s.length < policy.minLength) return false;
  if (policy.requireUppercase && !s.contains(RegExp(r'[A-Z]'))) return false;
  if (policy.requireLowercase && !s.contains(RegExp(r'[a-z]'))) return false;
  if (policy.requireNumber && !s.contains(RegExp(r'[0-9]'))) return false;
  if (policy.requireSpecial &&
      !s.contains(RegExp(r'[~!@#$%^&*()_\-+=|\\{}\[\]:;<>?/]'))) {
    return false;
  }
  return true;
}

// ── UUID ─────────────────────────────────────────────────────

/// Valida UUID. Por padrão aceita qualquer versão (`all`).
/// Versões suportadas: `'3'`, `'4'`, `'5'`, `'all'`.
bool isUuid(dynamic value, {String version = 'all'}) {
  if (value == null) return false;
  final s = value.toString().toUpperCase();

  final patterns = <String, RegExp>{
    '3': RegExp(
        r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$'),
    '4': RegExp(
        r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
    '5': RegExp(
        r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
    'all': RegExp(
        r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$'),
  };

  return patterns[version]?.hasMatch(s) ?? false;
}

// ── URL ──────────────────────────────────────────────────────

/// Valida URL com esquema `http`, `https` ou `ftp`.
bool isUrl(dynamic value) {
  final s = value?.toString() ?? '';
  return isAllowedUrl(s);
}

// ── IPv4 ─────────────────────────────────────────────────────

/// Valida endereço IPv4 no formato `0.0.0.0` a `255.255.255.255`.
bool isIpv4(dynamic value) {
  final s = value?.toString() ?? '';
  final parts = s.split('.');
  if (parts.length != 4) return false;
  return parts.every((p) {
    final n = int.tryParse(p);
    return n != null && n >= 0 && n <= 255 && p == n.toString();
  });
}

// ── IPv6 ─────────────────────────────────────────────────────

/// Valida endereço IPv6 em formato completo ou comprimido (com `::` e zonas).
bool isIpv6(dynamic value) {
  final s = value?.toString() ?? '';
  // Remove zona de link (ex: %eth0)
  final clean = s.split('%').first;
  return RegExp(
    r'^('
    r'([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|' // completo
    r'([0-9a-fA-F]{1,4}:){1,7}:|' // ::
    r':([0-9a-fA-F]{1,4}:){1,7}|' // ::x
    r'([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|' // x::x
    r'([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|'
    r'([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|'
    r'([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|'
    r'([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|'
    r'[0-9a-fA-F]{1,4}:(:[0-9a-fA-F]{1,4}){1,6}|'
    r'::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}'
    r'(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|' // ::ffff:IPv4
    r'([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}'
    r'(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|' // IPv4-mapped
    r'::([0-9a-fA-F]{1,4}:){0,5}[0-9a-fA-F]{1,4}|'
    r'[0-9a-fA-F]{1,4}::([0-9a-fA-F]{1,4}:){0,4}[0-9a-fA-F]{1,4}'
    r')$',
  ).hasMatch(clean);
}

// ── Regex genérico ───────────────────────────────────────────

/// Valida [value] contra um padrão regex arbitrário.
bool matchesRegex(dynamic value, String pattern) {
  final s = value?.toString() ?? '';
  return RegExp(pattern).hasMatch(s);
}
