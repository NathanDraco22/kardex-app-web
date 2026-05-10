import 'package:flutter/material.dart';

import '../view_controller.dart';


class ClientInvoiceWebMediator extends InheritedWidget {
  const ClientInvoiceWebMediator({
    super.key,
    required super.child,
    required this.viewController,
  });

  final ClientInvoiceViewController viewController;

  static ClientInvoiceWebMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClientInvoiceWebMediator>()!;
  }

  @override
  bool updateShouldNotify(ClientInvoiceWebMediator oldWidget) {
    return false;
  }
}
