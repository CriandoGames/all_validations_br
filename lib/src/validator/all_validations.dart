import 'dart:convert';

import 'package:all_validations_br/all_validations_br.dart';

import '../helpers/constants.dart';
import 'dart:developer' as developer;

class AllValidations {
  AllValidations._();

  //method help
  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  /// Checks if data is null.
  static bool isNull(dynamic value) => value == null;

  /// Checks if string is int or double.
  static bool isNum(String value) {
    if (isNull(value)) {
      return false;
    }

    return num.tryParse(value) is num;
  }

  /// Checks if string consist only numeric.
  /// Numeric only doesn't accepting "." which double data type have
  static bool isNumericOnly(String s) => hasMatch(s, r'^\d+$');

  /// Numeric only but '' return true
  static bool isNumericFloat(String s) => hasMatch(
      s, r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$');

  /// Checks if string consist only Alphabet. (No Whitespace)
  static bool isAlphabetOnly(String s) => hasMatch(s, r'^[a-zA-Z]+$');

  /// Checks if string is boolean.
  static bool isBool(String value) {
    if (isNull(value)) {
      return false;
    }

    return (value == 'true' || value == 'false');
  }

  /// Checks if string is an video file.
  static bool isVideo(String filePath) {
    var ext = filePath.toLowerCase();

    return ext.endsWith(".mp4") ||
        ext.endsWith(".wmv") ||
        ext.endsWith(".mpg") ||
        ext.endsWith(".3gp") ||
        ext.endsWith(".m4v") ||
        ext.endsWith(".mgv") ||
        ext.endsWith(".mov") ||
        ext.endsWith(".mkv") ||
        ext.endsWith(".ogv") ||
        ext.endsWith(".qtm") ||
        ext.endsWith(".srt") ||
        ext.endsWith(".amc") ||
        ext.endsWith(".dvx") ||
        ext.endsWith(".flv") ||
        ext.endsWith(".evo") ||
        ext.endsWith(".avi") ||
        ext.endsWith("rmvb") ||
        ext.endsWith(".mpg") ||
        ext.endsWith("mpeg");
  }

  /// Checks if string is an image file.
  static bool isImage(String filePath) {
    final ext = filePath.toLowerCase();

    return ext.endsWith(".jpg") ||
        ext.endsWith(".jpeg") ||
        ext.endsWith(".png") ||
        ext.endsWith(".gif") ||
        ext.endsWith(".ico") ||
        ext.endsWith(".svg") ||
        ext.endsWith(".raw") ||
        ext.endsWith(".bmp");
  }

  /// Checks if string is an audio file.
  static bool isAudio(String filePath) {
    final ext = filePath.toLowerCase();

    return ext.endsWith(".mp3") ||
        ext.endsWith(".wav") ||
        ext.endsWith(".wma") ||
        ext.endsWith(".amr") ||
        ext.endsWith(".ogg");
  }

  /// Checks if string is URL.
  static bool isURL(String s) => hasMatch(s,
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  /// Checks if string is email.
  static bool isEmail(String s) {
    if (hasMatch(
        s, r'[!#<>?":`~;[\]\\|=+)(*&^%áàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ]')) {
      return false;
    }

    return hasMatch(s,
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  }

  /// Checks if string is phone Cell Phone Brazilian.
  static bool isBrazilianCellPhone(String s) {
    // Remove caracteres não numéricos
    if (s.isEmpty) return false;

    String cleanedNumber = removeCharacters(s);

    // Verifica se o número contém o código de país (+55) e o remove
    if (cleanedNumber.startsWith("55")) {
      cleanedNumber = cleanedNumber.substring(2);
    }

    // Verifica o tamanho do número (11 dígitos para celular)
    if (cleanedNumber.length != 11) return false;

    // Extrai o DDD e valida contra a lista de DDDs válidos
    String ddd = cleanedNumber.substring(0, 2);
    if (!isValidDDD(ddd)) return false;

    // Verifica se o número começa com "9" (celular)
    String celularInicio = cleanedNumber.substring(2, 3);
    if (celularInicio != "9") return false;

    // Valida o formato geral do número
    return hasMatch(cleanedNumber, r'^[0-9]{11}$');
  }

  /// Valida se o número é um telefone fixo brasileiro com DDD.
  static bool isBrazilianLandline(String s) {
    if (s.isEmpty) return false;
    // Remove caracteres não numéricos
    String cleanedNumber = removeCharacters(s);

    // Verifica se o número contém o código de país (+55) e o remove
    if (cleanedNumber.startsWith("55")) {
      cleanedNumber = cleanedNumber.substring(2);
    }

    // Verifica o tamanho do número (10 dígitos para fixo)
    if (cleanedNumber.length != 10) return false;

    // Extrai o DDD e valida contra a lista de DDDs válidos
    String ddd = cleanedNumber.substring(0, 2);
    if (!isValidDDD(ddd)) return false;

    // Verifica se o número começa com um dígito válido para telefones fixos (2 a 5)
    String fixoInicio = cleanedNumber.substring(2, 3);
    if (!['2', '3', '4', '5'].contains(fixoInicio)) return false;

    // Valida o formato geral do número
    return hasMatch(cleanedNumber, r'^[0-9]{10}$');
  }

  static bool isValidDDD(String ddd) {
    return Constants.ddds.contains(ddd);
  }

  /// Retorna o estado correspondente ao DDD informado.
  BrazilianState getStateByDDD(String ddd) {
    const dddToStateMap = {
      "11": BrazilianState.SP,
      "12": BrazilianState.SP,
      "13": BrazilianState.SP,
      "14": BrazilianState.SP,
      "15": BrazilianState.SP,
      "16": BrazilianState.SP,
      "17": BrazilianState.SP,
      "18": BrazilianState.SP,
      "19": BrazilianState.SP,
      "21": BrazilianState.RJ,
      "22": BrazilianState.RJ,
      "24": BrazilianState.RJ,
      "27": BrazilianState.ES,
      "28": BrazilianState.ES,
      "31": BrazilianState.MG,
      "32": BrazilianState.MG,
      "33": BrazilianState.MG,
      "34": BrazilianState.MG,
      "35": BrazilianState.MG,
      "37": BrazilianState.MG,
      "38": BrazilianState.MG,
      "41": BrazilianState.PR,
      "42": BrazilianState.PR,
      "43": BrazilianState.PR,
      "44": BrazilianState.PR,
      "45": BrazilianState.PR,
      "46": BrazilianState.PR,
      "47": BrazilianState.SC,
      "48": BrazilianState.SC,
      "49": BrazilianState.SC,
      "51": BrazilianState.RS,
      "53": BrazilianState.RS,
      "54": BrazilianState.RS,
      "55": BrazilianState.RS,
      "61": BrazilianState.DF,
      "62": BrazilianState.GO,
      "64": BrazilianState.GO,
      "63": BrazilianState.TO,
      "65": BrazilianState.MT,
      "66": BrazilianState.MT,
      "67": BrazilianState.MS,
      "68": BrazilianState.AC,
      "69": BrazilianState.RO,
      "71": BrazilianState.BA,
      "73": BrazilianState.BA,
      "74": BrazilianState.BA,
      "75": BrazilianState.BA,
      "77": BrazilianState.BA,
      "79": BrazilianState.SE,
      "81": BrazilianState.PE,
      "87": BrazilianState.PE,
      "82": BrazilianState.AL,
      "83": BrazilianState.PB,
      "84": BrazilianState.RN,
      "85": BrazilianState.CE,
      "88": BrazilianState.CE,
      "86": BrazilianState.PI,
      "89": BrazilianState.PI,
      "91": BrazilianState.PA,
      "93": BrazilianState.PA,
      "94": BrazilianState.PA,
      "92": BrazilianState.AM,
      "97": BrazilianState.AM,
      "95": BrazilianState.RR,
      "96": BrazilianState.AP,
      "98": BrazilianState.MA,
      "99": BrazilianState.MA
    };

    return dddToStateMap[ddd] ?? BrazilianState.Unknown;
  }

  /// Checks if string is DateTime (UTC or Iso8601).
  static bool isDateTime(String s) =>
      hasMatch(s, r'^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}.\d{3}Z?$');

  /// Checks if string is MD5 hash.
  static bool isMD5(String s) => hasMatch(s, r'^[a-f0-9]{32}$');

  /// Checks if string is SHA1 hash.
  static bool isSHA1(String s) =>
      hasMatch(s, r'(([A-Fa-f0-9]{2}\:){19}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{40})');

  /// Checks if string is SHA256 hash.
  static bool isSHA256(String s) =>
      hasMatch(s, r'([A-Fa-f0-9]{2}\:){31}[A-Fa-f0-9]{2}|[A-Fa-f0-9]{64}');

  /// Checks if string is SSN (Social Security Number).
  static bool isSSN(String s) => hasMatch(s,
      r'^(?!0{3}|6{3}|9[0-9]{2})[0-9]{3}-?(?!0{2})[0-9]{2}-?(?!0{4})[0-9]{4}$');

  /// Checks if string is binary.
  static bool isBinary(String s) => hasMatch(s, r'^[0-1]+$');

  /// Checks if string is IPv4.
  static bool isIPv4(String s) =>
      hasMatch(s, r'^(?:(?:^|\.)(?:2(?:5[0-5]|[0-4]\d)|1?\d?\d)){4}$');

  /// Checks if string is IPv6.
  static bool isIPv6(String s) => hasMatch(s,
      r'^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$');

  /// Checks if string is hexadecimal.
  /// Example: HexColor => #12F
  static bool isHexadecimal(String s) =>
      hasMatch(s, r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');

  /// Checks if num a LOWER than num b.
  static bool isLowerThan(num a, num b) => a < b;

  /// Checks if num a GREATER than num b.
  static bool isGreaterThan(num a, num b) => a > b;

  /// Checks if num a EQUAL than num b.
  static bool isEqual(num a, num b) => a == b;

  //Check if num is a cnpj
  static bool isCnpj(String cnpj) {
    final numbers = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length != 14) {
      return false;
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
      return false;
    }

    final digits = numbers.split('').map(int.parse).toList();

    var calcDv1 = 0;
    var j = 0;
    for (var i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
      calcDv1 += digits[j++] * i;
    }
    calcDv1 %= 11;
    final dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

    if (digits[12] != dv1) {
      return false;
    }

    var calcDv2 = 0;
    j = 0;
    for (var i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
      calcDv2 += digits[j++] * i;
    }
    calcDv2 %= 11;
    final dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

    if (digits[13] != dv2) {
      return false;
    }

    return true;
  }

  /// Checks if the cpf is valid.
  static bool isCpf(String cpf) {
    // get only the numbers
    final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    // Test if the CPF has 11 digits
    if (numbers.length != 11) {
      return false;
    }
    // Test if all CPF digits are the same
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) {
      return false;
    }

    // split the digits
    final digits = numbers.split('').map(int.parse).toList();

    // Calculate the first verifier digit
    var calcDv1 = 0;
    for (var i in Iterable<int>.generate(9, (i) => 10 - i)) {
      calcDv1 += digits[10 - i] * i;
    }
    calcDv1 %= 11;

    final dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;

    // Tests the first verifier digit
    if (digits[9] != dv1) {
      return false;
    }

    // Calculate the second verifier digit
    var calcDv2 = 0;
    for (var i in Iterable<int>.generate(10, (i) => 11 - i)) {
      calcDv2 += digits[11 - i] * i;
    }
    calcDv2 %= 11;

    final dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;

    // Test the second verifier digit
    if (digits[10] != dv2) {
      return false;
    }

    return true;
  }

  /// Check if the string [str] is an integer
  static bool isInt(String str) {
    RegExp _int = new RegExp(r'^(?:-?(?:0|[1-9][0-9]*))$');
    return _int.hasMatch(str);
  }

  /// Check if the string [str] is lowercase
  static bool isLowercase(String str) {
    return str == str.toLowerCase();
  }

  /// Check if the string [str] is uppercase
  static bool isUppercase(String str) {
    return str == str.toUpperCase();
  }

  /// Remove special characters (ex: `/`, `-`, `.`)
  static String removeCharacters(String valor) {
    assert(valor.isNotEmpty, 'Valor não pode ser vazio');
    return valor.replaceAll(RegExp('[^0-9a-zA-Z]+'), '');
  }

  /// Remove Accents from Strings
  static String removeAccents(String phrase) {
    phrase.split('').forEach((value) => Constants.accents.forEach((acc) {
          if (value == acc) {
            int indexOfAccentChar = Constants.accents.indexOf(value);
            phrase = phrase.replaceFirst(
                value, Constants.noAccents[indexOfAccentChar]);
          }
        }));
    return phrase;
  }

  /// Check if the string is a credit card
  static bool isCreditCard(String str) {
    RegExp _creditCard = new RegExp(
        r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$');

    String sanitized = str.replaceAll(new RegExp(r'[^0-9]+'), '');
    if (!_creditCard.hasMatch(sanitized)) {
      return false;
    } else {
      return true;
    }
  }

  /// Check if the string is a UUID (version 3, 4 or 5).
  static bool isUUID(String? str, [version]) {
    Map _uuid = {
      '3': new RegExp(
          r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$'),
      '4': new RegExp(
          r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
      '5': new RegExp(
          r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
      'all': new RegExp(
          r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$')
    };

    if (version == null) {
      version = 'all';
    } else {
      version = version.toString();
    }

    RegExp? pat = _uuid[version];

    return (pat != null && pat.hasMatch(str!.toUpperCase()));
  }

  /// Check if the string is valid JSON
  static bool isJSON(str) {
    try {
      jsonDecode(str);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Check if CEP is valid format
  static bool isValidBRZip(String cep) {
    int len = cep.trim().length;
    RegExp isZipValid =
        RegExp(r'[0-9]{2}\.?[0-9]{3}-?[0-9]{3}', caseSensitive: false);
    return len >= 8 && len <= 10 && isZipValid.hasMatch(cep);
  }

  /// Check if RG is valid format included with x in end
  static bool isRG(String rg) =>
      hasMatch(rg, r'(^\d{1,2}).?(\d{3}).?(\d{3})-?(\d{1}|X|x$)');

  /// Check if Nickname is valid format
  static bool isNickname(String nickName) =>
      hasMatch(nickName, r'^[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]$');

  /// Checks if string is an pdf file.
  static bool isPDF(String filePath) {
    return filePath.toLowerCase().endsWith(".pdf");
  }

  /// Checks if string is an txt file.
  static bool isTxt(String filePath) {
    return filePath.toLowerCase().endsWith(".txt");
  }

  /// Checks if string is an chm file.
  static bool isChm(String filePath) {
    return filePath.toLowerCase().endsWith(".chm");
  }

  /// Checks if string is a vector file.
  static bool isVector(String filePath) {
    return filePath.toLowerCase().endsWith(".svg");
  }

  /// Checks if string is an html file.
  static bool isHTML(String filePath) {
    return filePath.toLowerCase().endsWith(".html");
  }

  static bool isMediumPassword(String password) => hasMatch(password,
      r"^(((?=.*[a-z])(?=.*[A-Z]))|((?=.*[a-z])(?=.*[0-9]))|((?=.*[A-Z])(?=.*[0-9])))(?=.{6,})");

  static bool isStrongPassword(String password) => hasMatch(password,
      r"^(?=.*\d)(?=.*[~!@#$%^&*()_\-+=|\\{}[\]:;<>?/])(?=.*[A-Z])(?=.*[a-z])\S{8,99}$");

  /// Checks if string is Palindrome.
  static bool isPalindrome(String string) {
    string = removeAccents(string);
    String cleanString = removeCharacters(string.toLowerCase());

    for (var i = 0; i < cleanString.length; i++) {
      if (cleanString[i] != cleanString[cleanString.length - i - 1]) {
        return false;
      }
    }
    return true;
  }

  static bool isValidBrazilianLicensePlate(String plate) {
    final oldModel = RegExp(r'^[A-Z]{3}-?\d{4}$'); // Ex.: ABC-1234
    final newModel = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$'); // Ex.: ABC1D23
    return oldModel.hasMatch(plate) || newModel.hasMatch(plate);
  }

  /// Valida se uma string é uma cor hexadecimal válida (#RRGGBB ou #RGB).
  static bool isValidHexColor(String color) {
    final RegExp hexColorRegex = RegExp(r'^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');
    return hexColorRegex.hasMatch(color);
  }

  /// Valida se um código de barras EAN-13 é válido.
  static bool isValidEAN13(String code) {
    if (code.length != 13 || !RegExp(r'^\d{13}$').hasMatch(code)) {
      return false;
    }

    List<int> digits = code.split('').map(int.parse).toList();
    int checksum = 0;

    for (int i = 0; i < 12; i++) {
      if (i % 2 == 0) {
        checksum += digits[i];
      } else {
        checksum += digits[i] * 3;
      }
    }

    int checkDigit = (10 - (checksum % 10)) % 10;

    return checkDigit == digits.last;
  }

  ///check if password is equal to confirm password or pharse is equal to confirm phrase
  static bool isPhraseEqual(String phase1, String phase2) {
    return phase1 == phase2;
  }

  /// Check if name not contain special character like #$%*@!
  static bool isName(String value) =>
      !hasMatch(value, r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');

  static bool isMapExists({required List<String> key, required Map map}) {
    for (var currentKey in key) {
      if (map.containsKey(currentKey)) {
        if (map[currentKey] != null) {
          if (map[currentKey].toString() == '') {
            developer.log(
              currentKey + ' is empty value',
            );
          }
          developer.log(
            currentKey + ' has value $map[currentKey]',
          );
        } else {
          developer.log('Error', error: currentKey + ' is null value');
          return false;
        }
      } else {
        developer.log('Error', error: currentKey + ' is not found');
        return false;
      }
    }
    return true;
  }
}
