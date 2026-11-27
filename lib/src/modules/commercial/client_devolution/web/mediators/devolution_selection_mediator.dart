import 'package:material_ui/material_ui.dart';
import 'package:kardex_business/kardex_business.dart';

class DevolutionSelectionViewController extends ChangeNotifier {
  final Map<int, SaleItem> _selectedByIndex = {};

  List<SaleItem> get selectedItems => _selectedByIndex.values.toList();

  String devolutionDescription = '';

  void toggleIndex(int index, SaleItem item, bool selected) {
    if (selected) {
      _selectedByIndex[index] = item;
    } else {
      _selectedByIndex.remove(index);
    }
    notifyListeners();
  }

  void addToSelected(SaleItem item) {
    final idx = item.invoiceItemIndex ?? _selectedByIndex.length;
    _selectedByIndex[idx] = item;
    notifyListeners();
  }

  void removeFromSelected(SaleItem item) {
    _selectedByIndex.removeWhere((_, value) => value == item);
    notifyListeners();
  }

  void clearSelected() {
    _selectedByIndex.clear();
    notifyListeners();
  }

  bool isIndexSelected(int index) => _selectedByIndex.containsKey(index);

  bool isInSelected(SaleItem item) => _selectedByIndex.containsValue(item);
}

class DevolutionSelectionMediator extends InheritedNotifier<DevolutionSelectionViewController> {
  const DevolutionSelectionMediator({super.key, required super.child, required super.notifier});

  static DevolutionSelectionMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DevolutionSelectionMediator>()!;
  }
}
