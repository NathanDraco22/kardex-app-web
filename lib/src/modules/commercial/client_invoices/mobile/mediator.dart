import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class InvoiceMobileViewController extends ChangeNotifier {
  List<CommercialProductResult> items = [];

  void addItem(CommercialProductResult item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(CommercialProductResult item) {
    items.remove(item);
    notifyListeners();
  }
}

class InvoiceMobileMediator extends InheritedWidget {
  const InvoiceMobileMediator({super.key, required super.child, required this.viewController});

  final InvoiceMobileViewController viewController;

  static InvoiceMobileMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InvoiceMobileMediator>()!;
  }

  @override
  bool updateShouldNotify(InvoiceMobileMediator oldWidget) {
    return false;
  }
}
