import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';

import '../widgets/client_invoice_table.dart';

class ViewController extends ChangeNotifier {
  DateTime? _selectedDate;

  String description = '';

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  ClientInDb? _selectedClient;

  ClientInDb? get selectedClient => _selectedClient;
  set selectedClient(ClientInDb? value) {
    final hasCredit = value?.isCreditActive ?? false;
    final initValue = hasCredit ? PaymentType.credit : PaymentType.cash;
    selectedPaymentType = initValue;
    _selectedClient = value;
    notifyListeners();
  }

  PaymentType selectedPaymentType = PaymentType.cash;

  void refresh() => notifyListeners();
}

class ClientInvoiceWebMediator extends InheritedWidget {
  const ClientInvoiceWebMediator({
    super.key,
    required super.child,
    required this.tableController,
    required this.viewController,
  });

  final ClientInvoiceTableController tableController;
  final ViewController viewController;

  static ClientInvoiceWebMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClientInvoiceWebMediator>()!;
  }

  @override
  bool updateShouldNotify(ClientInvoiceWebMediator oldWidget) {
    return false;
  }
}
