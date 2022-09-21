import '../Notifications/notifiable.dart';
import 'contract_validations.dart';

class Contract extends ContractValidations {
  Contract requires() => this;

  Contract join(List<FluntNotifiable> itens) {
    itens.forEach(
      (f) {
        if (f.invalid) {
          addNotifications(f.notifications);
        }
      },
    );
    return this;
  }
}
