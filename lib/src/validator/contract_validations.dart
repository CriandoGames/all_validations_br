import 'package:all_validations_br/all_validations_br.dart';

import '../Notifications/notifiable.dart';
import 'contract.dart';

class ContractValidations extends FluntNotifiable {
  isFalse(bool value, String property, String message) {
    if (!value) {
      addNotifications(FluntNotification(property: property, message: message));
    }
    return this;
  }

  Contract isTrue(bool value, String property, String message) =>
      isFalse(!value, property, message);

  isGreaterThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((comparer as DateTime)))
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if (value > comparer)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isGreaterOrEqualsThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((comparer as DateTime)))
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if (value >= comparer)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isLowerThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isBefore((comparer as DateTime)))
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if (value < comparer)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isLowerOrEqualsThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isBefore((comparer as DateTime)))
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if (value <= comparer)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  areEquals(dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).difference((comparer as DateTime)).inDays == 0)
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if (value == comparer)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  areNotEquals(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).difference((comparer as DateTime)).inDays != 0)
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if (value != comparer)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isBetween(dynamic value, dynamic from, dynamic into, String property,
      String message) {
    bool hasDatetime =
        ((value is DateTime) || (from is DateTime) || (into is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((from as DateTime)) ||
          (value).isBefore((into as DateTime)))
        addNotifications(
            FluntNotification(property: property, message: message));
      return this;
    }

    if ((value >= from && value <= into))
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isNullOrNullable(dynamic value, String property, String message) {
    if (value == null || value.HasValue)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isNotNullOrEmpty(dynamic val, String property, String message) {
    if (val == null || val.isEmpty)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isNullOrEmpty(String val, String property, String message) {
    if (val.isEmpty)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  hasMinLen(String val, int min, String property, String message) {
    if (val.isEmpty || val.length < min)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  hasMaxLen(String val, int max, String property, String message) {
    if (val.isEmpty || val.length > max)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  hasLen(String val, int len, String property, String message) {
    if (val.isEmpty || val.length != len)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  contains(String val, String text, String property, String message) {
    if (!val.contains(text))
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isDigit(String text, String property, String message) {
    var numeric = RegExp('^\d+\$');

    if (!numeric.hasMatch(text)) {
      addNotifications(FluntNotification(property: property, message: message));
    }
    return this;
  }

  hasMinLengthIfNotNullOrEmpty(
      String text, int min, String property, String message) {
    if (text.isNotEmpty && text.length < min)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  hasMaxLengthIfNotNullOrEmpty(
      String text, int max, String property, String message) {
    if (text.isNotEmpty && text.length > max)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  hasExactLengthIfNotNullOrEmpty(
      String text, int len, String property, String message) {
    if (text.isNotEmpty && text.length != len)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isEmail(String email, String property, String message) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);

    if (!emailValid)
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isValidCPF(String cpf, String property, String message) {
    if (!_isValid(cpf))
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }

  isValidCNPJ(String cnpj, String property, String message) {
    if (!_isValidCNPJ(cnpj))
      addNotifications(FluntNotification(property: property, message: message));

    return this;
  }
}

bool _isValid(String? cpf) {
  if (cpf == null) return false;
  return AllValidations.isCpf(cpf);
}

bool _isValidCNPJ(String? cnpj) {
  if (cnpj == null) return false;
  return AllValidations.isCpf(cnpj);
}
