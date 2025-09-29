import 'package:flutter/material.dart';
import 'widgets/anon_invoice_table.dart';

class AnonInvoiceViewController extends ChangeNotifier {
  String description = '';

  void refresh() => notifyListeners();
}

class AnonInvoiceWebMediator extends InheritedWidget {
  const AnonInvoiceWebMediator({
    super.key,
    required super.child,
    required this.tableController,
    required this.viewController,
  });

  final AnonInvoiceTableController tableController;
  final AnonInvoiceViewController viewController;

  static AnonInvoiceWebMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnonInvoiceWebMediator>()!;
  }

  @override
  bool updateShouldNotify(AnonInvoiceWebMediator oldWidget) {
    return false;
  }
}
