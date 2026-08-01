/// Funções puras de validação genérica usadas pelo [BrZod].
///
/// Separadas da classe principal para facilitar testes unitários
/// e eventual extração do módulo como pacote standalone.
library;

import '../../helpers/constants.dart';
import '../../validator/internal/email_validator.dart';

/// Retorna `true` se [value] não é nulo e não é string vazia.
bool isRequired(dynamic value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  return true;
}

/// Retorna `true` se [value] é nulo ou string vazia (campo opcional presente).
bool isEmpty(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  return false;
}

/// Retorna `true` se o comprimento de [value] é >= [n].
bool hasMinLength(dynamic value, int n) {
  final str = value?.toString() ?? '';
  return str.length >= n;
}

/// Retorna `true` se o comprimento de [value] é <= [n].
bool hasMaxLength(dynamic value, int n) {
  final str = value?.toString() ?? '';
  return str.length <= n;
}

/// Retorna `true` se [value] é um e-mail válido.
bool isEmail(dynamic value) {
  final str = value?.toString() ?? '';
  return isAllowedEmail(str);
}

/// Retorna `true` se [value] é um telefone brasileiro válido
/// (celular 9 dígitos ou fixo 8 dígitos, com ou sem DDD).
bool isPhone(dynamic value) {
  final input = value?.toString() ?? '';
  final acceptedFormat = RegExp(
    r'^(?:\d{8,11}|\(\d{2}\) \d{4}-\d{4}|\(\d{2}\) \d{5}-\d{4})$',
  );
  if (!acceptedFormat.hasMatch(input)) return false;

  final digits = input.replaceAll(RegExp(r'[() -]'), '');
  switch (digits.length) {
    case 8:
      return RegExp(r'^[2-5]\d{7}$').hasMatch(digits);
    case 9:
      return RegExp(r'^9\d{8}$').hasMatch(digits);
    case 10:
      return Constants.ddds.contains(digits.substring(0, 2)) &&
          RegExp(r'^[2-5]\d{7}$').hasMatch(digits.substring(2));
    case 11:
      return Constants.ddds.contains(digits.substring(0, 2)) &&
          RegExp(r'^9\d{8}$').hasMatch(digits.substring(2));
    default:
      return false;
  }
}

/// Retorna `true` se [value] == [other] após conversão para String.
bool isEquals(dynamic value, dynamic other) {
  return value?.toString() == other?.toString();
}

/// Retorna `true` se [value] é do tipo [T].
bool isType<T>(dynamic value) {
  if (T == String) return value is String;
  if (T == int) {
    if (value is int) return true;
    return int.tryParse(value?.toString() ?? '') != null;
  }
  if (T == double) {
    if (value is double) return true;
    return double.tryParse(value?.toString() ?? '') != null;
  }
  if (T == bool) {
    if (value is bool) return true;
    final s = value?.toString().toLowerCase();
    return s == 'true' || s == 'false';
  }
  return value is T;
}

/// Retorna `true` se [value] pode ser interpretado como uma data válida.
///
/// Aceita formatos: `dd/MM/yyyy`, `yyyy-MM-dd` e ISO 8601.
bool isDate(dynamic value) {
  return _parseDate(value) != null;
}

/// Retorna `true` se [value] representa uma data anterior a [max].
bool isBeforeDate(dynamic value, DateTime max) {
  final date = _parseDate(value);
  return date != null && date.isBefore(max);
}

/// Retorna `true` se [value] representa uma data posterior a [min].
bool isAfterDate(dynamic value, DateTime min) {
  final date = _parseDate(value);
  return date != null && date.isAfter(min);
}

// ── Helpers internos ────────────────────────────────────────

DateTime? _parseDate(dynamic value) {
  final str = value?.toString().trim() ?? '';
  if (str.isEmpty) return null;

  final brMatch = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(str);
  if (brMatch != null) {
    final day = int.parse(brMatch.group(1)!);
    final month = int.parse(brMatch.group(2)!);
    final year = int.parse(brMatch.group(3)!);
    if (!_isValidCalendarDate(year, month, day)) return null;
    return DateTime(year, month, day);
  }

  final isoMatch = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:[.,]\d{1,6})?)?(Z|[+-]\d{2}:?\d{2})?)?$',
  ).firstMatch(str);
  if (isoMatch == null) return null;

  final year = int.parse(isoMatch.group(1)!);
  final month = int.parse(isoMatch.group(2)!);
  final day = int.parse(isoMatch.group(3)!);
  if (!_isValidCalendarDate(year, month, day)) return null;

  final hour = int.tryParse(isoMatch.group(4) ?? '0') ?? -1;
  final minute = int.tryParse(isoMatch.group(5) ?? '0') ?? -1;
  final second = int.tryParse(isoMatch.group(6) ?? '0') ?? -1;
  if (hour > 23 || minute > 59 || second > 59) return null;

  final timezone = isoMatch.group(7);
  if (timezone != null && timezone != 'Z') {
    final timezoneMatch =
        RegExp(r'^[+-](\d{2}):?(\d{2})$').firstMatch(timezone);
    if (timezoneMatch == null ||
        int.parse(timezoneMatch.group(1)!) > 23 ||
        int.parse(timezoneMatch.group(2)!) > 59) {
      return null;
    }
  }

  return DateTime.tryParse(str);
}

bool _isValidCalendarDate(int year, int month, int day) {
  if (month < 1 || month > 12) return false;
  if (day < 1) return false;
  final daysInMonth = [
    0,
    31,
    _isLeapYear(year) ? 29 : 28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];
  return day <= daysInMonth[month];
}

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
