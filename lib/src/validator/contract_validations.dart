import 'package:all_validations_br/all_validations_br.dart';

class ContractValidations extends ValidationNotifiable {
  ContractValidations isFalse(bool value, String property, String message) {
    if (!value) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isTrue(bool value, String property, String message) =>
      isFalse(!value, property, message);

  ContractValidations isGreaterThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((comparer as DateTime)))
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if (value > comparer)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isGreaterOrEqualsThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((comparer as DateTime)))
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if (value >= comparer)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isLowerThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isBefore((comparer as DateTime)))
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if (value < comparer)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isLowerOrEqualsThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isBefore((comparer as DateTime)))
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if (value <= comparer)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations areEquals(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).difference((comparer as DateTime)).inDays == 0)
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if (value == comparer)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations areNotEquals(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).difference((comparer as DateTime)).inDays != 0)
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if (value != comparer)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isBetween(dynamic value, dynamic from, dynamic into,
      String property, String message) {
    bool hasDatetime =
        ((value is DateTime) || (from is DateTime) || (into is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((from as DateTime)) ||
          (value).isBefore((into as DateTime)))
        addNotifications(
            ValidationNotification(property: property, message: message));
      return this;
    }

    if ((value >= from && value <= into))
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isNullOrNullable(
      dynamic value, String property, String message) {
    if (value == null || value.HasValue)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isNotNullOrEmpty(
      dynamic val, String property, String message) {
    if (val == null || val.isEmpty)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isNullOrEmpty(
      String val, String property, String message) {
    if (val.isEmpty)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations hasMinLen(
      String val, int min, String property, String message) {
    if (val.isEmpty || val.length < min)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations hasMaxLen(
      String val, int max, String property, String message) {
    if (val.isEmpty || val.length > max)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations hasLen(
      String val, int len, String property, String message) {
    if (val.isEmpty || val.length != len)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations contains(
      String val, String text, String property, String message) {
    if (!val.contains(text))
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isDigit(String text, String property, String message) {
    var numeric = RegExp('^\d+\$');

    if (!numeric.hasMatch(text)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations hasMinLengthIfNotNullOrEmpty(
      String text, int min, String property, String message) {
    if (text.isNotEmpty && text.length < min)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations hasMaxLengthIfNotNullOrEmpty(
      String text, int max, String property, String message) {
    if (text.isNotEmpty && text.length > max)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations hasExactLengthIfNotNullOrEmpty(
      String text, int len, String property, String message) {
    if (text.isNotEmpty && text.length != len)
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isEmail(String email, String property, String message) {
    if (!AllValidations.isCpf(email))
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isValidCPF(String cpf, String property, String message) {
    if (!AllValidations.isCpf(cpf))
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }

  ContractValidations isValidCNPJ(
      String cnpj, String property, String message) {
    if (!AllValidations.isCnpj(cnpj))
      addNotifications(
          ValidationNotification(property: property, message: message));

    return this;
  }
}
