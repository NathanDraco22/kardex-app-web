import 'package:flutter/material.dart';
import '../view_controller.dart';

class AnonInvoiceMobileMediator extends InheritedWidget {
  const AnonInvoiceMobileMediator({
    super.key,
    required super.child,
    required this.viewController,
  });

  final AnonInvoiceViewController viewController;

  static AnonInvoiceMobileMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnonInvoiceMobileMediator>()!;
  }

  @override
  bool updateShouldNotify(AnonInvoiceMobileMediator oldWidget) {
    return false;
  }
}
