import 'dart:developer' as dev;
import 'package:all_validations_br/all_validations_br.dart';

class ValidationNotifiable {
  late List<ValidationNotification> _notifications;

  List<ValidationNotification> get notifications => _notifications;

  ValidationNotifiable() {
    _notifications = <ValidationNotification>[];
  }

  void addNotifications<T>(T r) {
    if (r is ValidationNotification) {
      _notifications.add(r);
    } else if (r is List<ValidationNotification>) {
      _notifications.addAll(r);
    } else if (r is Contract) {
      _notifications.addAll(r.notifications);
    } else if (r is List) {
      if (r.length > 1 && r[0] is String && r[1] is String) {
        _notifications.add(
          ValidationNotification(property: r[0], message: r[1]),
        );
      }
    }
  }

  /// Imprime todas as mensagens de erro.
  void printMessageErrors() {
    if (_notifications.isEmpty) {
      dev.log('Não existe Erro');
    } else {
      for (var tempNotification in _notifications) {
        dev.log(tempNotification.toString());
      }
    }
  }

  bool get invalid => _notifications.isNotEmpty;
  bool get isValid => !invalid;
}

class ValidationNotification {
  final String property;
  final String message;

  ValidationNotification({required this.property, required this.message});

  /// Converte a notificação para um mapa (JSON).
  Map<String, dynamic> toMap() {
    return {
      "property": property,
      "message": message,
    };
  }

  @override
  String toString() => "Property: $property , Message: $message";
}
