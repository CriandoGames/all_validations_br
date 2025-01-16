import 'package:all_validations_br/all_validations_br.dart';

class ContractValidations extends ValidationNotifiable {
  ContractValidations isFalse(bool value, String property, String message) {
    if (!value) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isStrongPassword(
      String password, String property, String message) {
    // Verifica se a senha é nula ou vazia
    if (password.isEmpty) {
      addNotifications(ValidationNotification(
          property: property, message: "A senha não pode estar vazia."));
      return this;
    }

    // Regex corrigida para validar senha forte
    final strongPasswordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

    if (!strongPasswordRegex.hasMatch(password)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isURL(String url, String property, String message) {
    if (!RegExp(r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$').hasMatch(url)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isPhoneNumber(
      String phone, String property, String message) {
    if (!AllValidations.isBrazilianCellPhone(phone) &&
        !AllValidations.isBrazilianLandline(phone)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isValidBRZip(
      String zip, String property, String message) {
    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(zip)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isUUID(String value, String property, String message) {
    if (!RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(value)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isPalindrome(
      String value, String property, String message) {
    String cleanedValue = value.replaceAll(RegExp(r'[\W_]+'), '').toLowerCase();
    String reversedValue = cleanedValue.split('').reversed.join();
    if (cleanedValue != reversedValue) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations customValidation(
      bool Function() validator, String property, String message) {
    if (!validator()) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isEnum<T>(
      dynamic value, List<T> enumValues, String property, String message) {
    if (!enumValues.contains(value)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isBefore(
      DateTime startDate, DateTime endDate, String property, String message) {
    if (!startDate.isBefore(endDate)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  ContractValidations isUnique(
      dynamic value, List<dynamic> list, String property, String message) {
    if (list.contains(value)) {
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
      if ((value as DateTime).isAfter((comparer as DateTime))) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if (value > comparer) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isGreaterOrEqualsThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((comparer as DateTime))) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if (value >= comparer) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isLowerThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isBefore((comparer as DateTime))) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if (value < comparer) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isLowerOrEqualsThan(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isBefore((comparer as DateTime))) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if (value <= comparer) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations areEquals(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).difference((comparer as DateTime)).inDays == 0) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if (value == comparer) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations areNotEquals(
      dynamic value, dynamic comparer, String property, String message) {
    bool hasDatetime = ((value is DateTime) || (comparer is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).difference((comparer as DateTime)).inDays != 0) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if (value != comparer) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isBetween(dynamic value, dynamic from, dynamic into,
      String property, String message) {
    bool hasDatetime =
        ((value is DateTime) || (from is DateTime) || (into is DateTime));

    if (hasDatetime) {
      if ((value as DateTime).isAfter((from as DateTime)) ||
          (value).isBefore((into as DateTime))) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }

      return this;
    }

    if ((value >= from && value <= into)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isNullOrNullable(
      dynamic value, String property, String message) {
    // Verifica se o valor é nulo
    if (value == null) {
      addNotifications(
          ValidationNotification(property: property, message: message));
      return this;
    }

    // Verifica tipos primitivos
    if (value is String && value.isEmpty) {
      addNotifications(ValidationNotification(
          property: property, message: "String vazia não é permitida."));
    } else if (value is List && value.isEmpty) {
      addNotifications(ValidationNotification(
          property: property, message: "Lista vazia não é permitida."));
    } else if (value is Map && value.isEmpty) {
      addNotifications(ValidationNotification(
          property: property, message: "Mapa vazio não é permitido."));
    } else if (value is bool) {
      // Nada a validar para booleanos, apenas retorna.
    } else if (value is num) {
      // Valida números (int e double)
      if (value.isNaN) {
        addNotifications(ValidationNotification(
            property: property, message: "Número inválido (NaN)."));
      }
    } else if (value is Object) {
      // Verifica objetos personalizados
      if (value.toString().isEmpty) {
        addNotifications(ValidationNotification(
            property: property,
            message: "Objeto não pode ser nulo ou inválido."));
      }
    }

    return this;
  }

  ContractValidations isNotNullOrEmpty(
      dynamic val, String property, String message) {
    if (val == null || val.isEmpty) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isNullOrEmpty(
      String val, String property, String message) {
    if (val.isEmpty) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations hasMinLen(
      String val, int min, String property, String message) {
    if (val.isEmpty || val.length < min) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations hasMaxLen(
      String val, int max, String property, String message) {
    if (val.isEmpty || val.length > max) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations hasLen(
      String val, int len, String property, String message) {
    if (val.isEmpty || val.length != len) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations contains(
      String val, String text, String property, String message) {
    if (!val.contains(text)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isDigit(String text, String property, String message) {
    // Remove espaços em branco e pontos
    String cleanedText =
        text.replaceAll(RegExp(r'\s+'), '').replaceAll('.', '');

    // Verifica se o texto contém apenas dígitos
    var numeric = RegExp(r'^\d+$');
    if (!numeric.hasMatch(cleanedText)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations hasMinLengthIfNotNullOrEmpty(
      String text, int min, String property, String message) {
    if (text.isNotEmpty && text.length < min) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations hasMaxLengthIfNotNullOrEmpty(
      String text, int max, String property, String message) {
    if (text.isNotEmpty && text.length > max) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations hasExactLengthIfNotNullOrEmpty(
      String text, int len, String property, String message) {
    if (text.isNotEmpty && text.length != len) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isEmail(String email, String property, String message) {
    if (!AllValidations.isEmail(email)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isValidCPF(String cpf, String property, String message) {
    if (!AllValidations.isCpf(cpf)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }

  ContractValidations isValidCNPJ(
      String cnpj, String property, String message) {
    if (!AllValidations.isCnpj(cnpj)) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }

    return this;
  }
}
