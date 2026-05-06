import 'package:flutter/material.dart';

import '../view_controller.dart';
import '../widgets/client_invoice_table.dart';

class ClientInvoiceWebMediator extends InheritedWidget {
  const ClientInvoiceWebMediator({
    super.key,
    required super.child,
    required this.tableController,
    required this.viewController,
  });

  final ClientInvoiceTableController tableController;
  final ClientInvoiceViewController viewController;

  static ClientInvoiceWebMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClientInvoiceWebMediator>()!;
  }

  @override
  bool updateShouldNotify(ClientInvoiceWebMediator oldWidget) {
    return false;
  }
}
