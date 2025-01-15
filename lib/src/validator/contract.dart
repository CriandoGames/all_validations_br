import '../Notifications/notifiable.dart';
import 'contract_validations.dart';

class Contract extends ContractValidations {
  /// Inicia a validação
  Contract requires() => this;

  /// Junta notificações de múltiplos objetos que implementam [ValidationNotifiable].
  Contract join(List<ValidationNotifiable> itens) {
    itens.forEach((f) {
      if (f.invalid) {
        addNotifications(f.notifications);
      }
    });
    return this;
  }

  /// Verifica se todas as notificações são válidas.
  bool get isValid => notifications.isEmpty;

  /// Adiciona notificações de outra instância de [Contract].
  Contract merge(Contract other) {
    addNotifications(other.notifications);
    return this;
  }

  /// Verifica múltiplos contratos, parando na primeira falha (lazy evaluation).
  Contract checkAll(
      List<bool Function()> validations, String property, String message) {
    for (var validation in validations) {
      if (!validation()) {
        addNotifications(
            ValidationNotification(property: property, message: message));
        break;
      }
    }
    return this;
  }

  /// Verifica múltiplos contratos, adicionando todas as falhas.
  Contract checkAllStrict(
      List<bool Function()> validations, String property, String message) {
    validations.forEach((validation) {
      if (!validation()) {
        addNotifications(
            ValidationNotification(property: property, message: message));
      }
    });
    return this;
  }

  /// Adiciona uma validação customizada.
  Contract addCustomValidation(
      bool Function() validation, String property, String message) {
    if (!validation()) {
      addNotifications(
          ValidationNotification(property: property, message: message));
    }
    return this;
  }

  /// Adiciona uma notificação personalizada sem validação.
  Contract addNotification(String property, String message) {
    addNotifications(
        ValidationNotification(property: property, message: message));
    return this;
  }

  /// Limpa todas as notificações.
  Contract clearNotifications() {
    notifications.clear();
    return this;
  }

  /// Retorna uma string com todas as mensagens de erro.
  String get allMessages => notifications.map((n) => n.message).join(', ');

  /// Exporta todas as notificações para um JSON.
  Map<String, dynamic> toJson() {
    return {
      "isValid": isValid,
      "notifications": notifications.map((n) => n.toMap()).toList(),
    };
  }
  
}
