import 'dart:convert';
import 'dart:io';
import 'dart:math';

class HelperUtil {
  /// Decodifica um JWT (JSON Web Token) e retorna seu payload.
  static Map<String, dynamic>? decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload);
    } catch (e) {
      return null;
    }
  }

  /// Obtém informações sobre o dispositivo.
  static Map<String, dynamic> getDeviceInfo() {
    return {
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'dartVersion': Platform.version,
    };
  }

  /// Converte UTC para horário local.
  static DateTime convertUtcToLocal(DateTime utcDate) => utcDate.toLocal();

  /// Converte horário local para UTC.
  static DateTime convertLocalToUtc(DateTime localDate) => localDate.toUtc();

  /// Valida uma chave PIX (CPF, e-mail, celular, chave aleatória).
  static String? validatePixKey(String key) {
    if (RegExp(r'^\d{11}$').hasMatch(key)) return 'CPF'; // CPF
    if (RegExp(r'^\+55\d{11}$').hasMatch(key)) return 'Celular'; // Celular
    if (RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
        .hasMatch(key)) return 'Email'; // Email
    if (key.length == 32 && RegExp(r'^[a-f0-9]{32}$').hasMatch(key))
      return 'Chave Aleatória'; // Chave Aleatória
    return null; // Chave inválida
  }

  /// Formata texto para diferentes padrões.
  static String? formatText(String input, String type) {
    switch (type.toLowerCase()) {
      case 'celular':
        return input.replaceAll(RegExp(r'\D'), '').replaceFirstMapped(
              RegExp(r'^(\d{2})(\d{5})(\d{4})$'),
              (m) => '(${m[1]}) ${m[2]}-${m[3]}',
            );
      case 'data':
        final dateParts = input.split('-');
        if (dateParts.length == 3) {
          return '${dateParts[2].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}/${dateParts[0]}';
        }
        break;
      case 'dinheiro':
        final value = double.tryParse(input);
        if (value != null) {
          return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
        }
        break;
      case 'hora':
        final timeParts = input.split(':');
        if (timeParts.length == 3) {
          return '${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}:${timeParts[2].padLeft(2, '0')}';
        }
        break;
      case 'cpf':
        return input.replaceAll(RegExp(r'\D'), '').replaceFirstMapped(
              RegExp(r'^(\d{3})(\d{3})(\d{3})(\d{2})$'),
              (m) => '${m[1]}.${m[2]}.${m[3]}-${m[4]}',
            );
      case 'cnpj':
        return input.replaceAll(RegExp(r'\D'), '').replaceFirstMapped(
              RegExp(r'^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$'),
              (m) => '${m[1]}.${m[2]}.${m[3]}/${m[4]}-${m[5]}',
            );
      case 'email':
        return input.trim().toLowerCase();
      default:
        return null;
    }
    return null;
  }

  /// Gera um número inteiro aleatório dentro de um intervalo.
  static int generateRandomInt(int min, int max) {
    final rand = Random();
    return min + rand.nextInt(max - min + 1);
  }

  static double calculatePercentage(double value, double total) {
    if (total == 0) throw ArgumentError("O total não pode ser zero.");
    return (value / total) * 100;
  }

  /// Calcula a idade com base na data de nascimento.
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Remove todos os caracteres não numéricos de uma string.
  static String removeNonNumeric(String input) {
    final regex = RegExp(r'[^0-9]');
    return input.replaceAll(regex, '');
  }

  /// Formata um número para o padrão de moeda brasileiro 
static String formatCurrency(double value) {
  // Arredonda o valor para duas casas decimais
  String formattedValue = value.toStringAsFixed(2);

  // Divide o número em parte inteira e decimal
  List<String> parts = formattedValue.split('.');

  // Adiciona separador de milhares
  String integerPart = parts[0];
  String formattedIntegerPart = '';
  for (int i = integerPart.length - 1, j = 0; i >= 0; i--, j++) {
    if (j > 0 && j % 3 == 0) {
      formattedIntegerPart = '.' + formattedIntegerPart;
    }
    formattedIntegerPart = integerPart[i] + formattedIntegerPart;
  }

  // Retorna o número formatado com o símbolo de moeda
  return 'R\$ $formattedIntegerPart,${parts[1]}';
}


  /// Calcula a diferença em dias entre duas datas.
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Gera uma string aleatória de tamanho especificado.
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  /// Converte a primeira letra de cada palavra para maiúscula.
  static String capitalizeWords(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Calcula o número de dias úteis entre duas datas.
  static int businessDaysBetween(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(Duration(days: 1));
    }
    return count;
  }

  /// Verifica se o ano é bissexto.
  static bool isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        return year % 400 == 0;
      }
      return true;
    }
    return false;
  }


  /// Criptografa uma senha usando chave de segurança e salt.
  static String encryptPassword(String password, String securityKey, String salt) {
    if (password.isEmpty || securityKey.isEmpty || salt.isEmpty) {
      throw ArgumentError("A senha, chave de segurança e salt não podem estar vazios.");
    }

    // Combina salt, chave de segurança e senha
    final combined = '$salt$securityKey$password';

    // Aplica um algoritmo hash simples
    final hash = _customHash(combined);

    // Retorna o salt combinado com o hash para armazenamento
    return '$salt:$hash';
  }

  /// Valida a senha comparando com o hash armazenado.
  static bool validatePassword(String password, String securityKey, String encryptedPassword) {
    final parts = encryptedPassword.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final hash = parts[1];

    // Gera o hash novamente e compara
    final newHash = encryptPassword(password, securityKey, salt).split(':')[1];
    return hash == newHash;
  }

  /// Algoritmo hash customizado (interno).
  static String _customHash(String input) {
    // Transforma a entrada em bytes
    final bytes = utf8.encode(input);

    // Faz manipulações simples nos bytes
    int hash = 0;
    for (final byte in bytes) {
      hash = (hash + byte) * 31; // Combinação de soma e multiplicação
      hash = hash & 0xFFFFFFFF; // Garante que o valor permaneça em 32 bits
    }

    // Converte o hash para uma string hexadecimal
    return hash.toRadixString(16).padLeft(8, '0');
  }

}
