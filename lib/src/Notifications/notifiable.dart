import '../validator/contract.dart';
import 'dart:developer' as dev;

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
      for (var f in r.notifications) {
        _notifications.add(f as ValidationNotification);
      }
    } else if (r is List) {
      if (r.length > 1) {
        _notifications
            .add(ValidationNotification(property: r[0], message: r[1]));
      }
    }
  }

  ///print all errors
  void printMessageErros() {
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
  late String _property;
  late String _message;

  ValidationNotification({required String property, required String message}) {
    _property = property;
    _message = message;
  }

  String get property => _property;
  String get message => _message;

  @override
  String toString() => "Property: $_property , Message: $_message";
}
