import 'package:flutter/widgets.dart';
import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/widgets/custom_listviews/inventory_movement_product_list_view.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';

class AdjustExitHeaderData {
  String? description;
  DateTime? docDate;
  AdjustExitType type = AdjustExitType.loss; // Default to loss or adjust? Assuming adjust logic applies.
}

class AdjustExitNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

class AdjustExitMediator extends InheritedNotifier<AdjustExitNotifier> {
  final AdjustExitType type;

  AdjustExitMediator({
    super.key,
    required super.child,
    required super.notifier,
    required this.type,
  }) {
    headerData.type = type;
  }

  static AdjustExitMediator? read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AdjustExitMediator>();
    return element?.widget as AdjustExitMediator?;
  }

  static AdjustExitMediator? watch(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdjustExitMediator>()!;
  }

  final AdjustExitHeaderData headerData = AdjustExitHeaderData();
  final ProductTableController productTableController = ProductTableController();
  final ProductListViewController productListViewController = ProductListViewController();

  void refresh() {
    notifier?.refresh();
  }

  bool hasAllRequiredFields() {
    if (productTableController.rows.isEmpty) return false;
    return true;
  }

  bool hasMobileAllRequiredFields() {
    if (productListViewController.rowCards.isEmpty) return false;
    return true;
  }
}
