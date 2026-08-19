import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class DevolutionsSelectionViewController extends ChangeNotifier {
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

class DevolutionsSelectionMediator extends InheritedNotifier<DevolutionsSelectionViewController> {
  const DevolutionsSelectionMediator({super.key, required super.child, required super.notifier});

  static DevolutionsSelectionMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DevolutionsSelectionMediator>()!;
  }
}
