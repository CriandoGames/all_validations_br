import '../validator/contract.dart';

class ValidationNotifiable {
  late List<FluntNotification> _notifications;

  List<FluntNotification> get notifications => _notifications;

  ValidationNotifiable() {
    _notifications = <FluntNotification>[];
  }

  void addNotifications<T>(T r) {
    if (r is FluntNotification) {
      _notifications.add(r);
    } else if (r is List<FluntNotification>) {
      _notifications.addAll(r);
    } else if (r is Contract) {
      r.notifications.forEach((f) => _notifications.add(f));
    } else if (r is List) {
      if (r.length > 1) {
        _notifications.add(FluntNotification(property: r[0], message: r[1]));
      }
    }
  }

  bool get invalid => _notifications.length != 0;
  bool get isValid => !invalid;
}

class FluntNotification {
  late String _property;
  late String _message;

  FluntNotification({required String property, required String message}) {
    _property = property;
    _message = message;
  }

  String get property => _property;
  String get message => _message;
}
