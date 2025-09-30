import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class AnonInvoiceMobileViewController extends ChangeNotifier {
  List<CommercialProductResult> items = [];

  void addItemIfNotExists(CommercialProductResult item) {
    final isExists = items.any((element) => element.product.id == item.product.id);
    if (isExists) return;
    items.add(item);
    notifyListeners();
  }

  int get totalItems => items.length;

  int get totalAmount => items.fold<int>(0, (previousValue, element) => previousValue + element.total);

  void updateItem(CommercialProductResult oldItem, CommercialProductResult newItem) {
    final index = items.indexOf(oldItem);
    items[index] = newItem;
    notifyListeners();
  }

  void removeItem(CommercialProductResult item) {
    items.remove(item);
    notifyListeners();
  }
}

class AnonInvoiceMobileMediator extends InheritedWidget {
  const AnonInvoiceMobileMediator({super.key, required super.child, required this.viewController});

  final AnonInvoiceMobileViewController viewController;

  static AnonInvoiceMobileMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnonInvoiceMobileMediator>()!;
  }

  @override
  bool updateShouldNotify(AnonInvoiceMobileMediator oldWidget) {
    return false;
  }
}
