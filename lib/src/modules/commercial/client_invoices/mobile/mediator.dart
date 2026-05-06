import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/view_controller.dart';

class InvoiceMobileMediator extends InheritedWidget {
  const InvoiceMobileMediator({super.key, required super.child, required this.viewController});

  final ClientInvoiceViewController viewController;

  static InvoiceMobileMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InvoiceMobileMediator>()!;
  }

  @override
  bool updateShouldNotify(InvoiceMobileMediator oldWidget) {
    return false;
  }
}
