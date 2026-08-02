import 'package:flutter/material.dart';
import '../view_controller.dart';

class AnonInvoiceWebMediator extends InheritedWidget {
  const AnonInvoiceWebMediator({
    super.key,
    required super.child,
    required this.viewController,
  });

  final AnonInvoiceViewController viewController;

  static AnonInvoiceWebMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnonInvoiceWebMediator>()!;
  }

  @override
  bool updateShouldNotify(AnonInvoiceWebMediator oldWidget) {
    return false;
  }
}
