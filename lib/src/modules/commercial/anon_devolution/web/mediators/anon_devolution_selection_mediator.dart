import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';

class AnonDevolutionSelectionViewController extends ChangeNotifier {
  List<SaleItem> _selectedItems = [];

  List<SaleItem> get selectedItems => _selectedItems;

  String devolutionDescription = '';

  void addToSelected(SaleItem item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeFromSelected(SaleItem item) {
    _selectedItems.remove(item);
    notifyListeners();
  }

  void clearSelected() {
    _selectedItems = [];
    notifyListeners();
  }

  bool isInSelected(SaleItem item) => _selectedItems.contains(item);
}

class AnonDevolutionSelectionMediator extends InheritedNotifier<AnonDevolutionSelectionViewController> {
  const AnonDevolutionSelectionMediator({super.key, required super.child, required super.notifier});

  static AnonDevolutionSelectionMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnonDevolutionSelectionMediator>()!;
  }
}
