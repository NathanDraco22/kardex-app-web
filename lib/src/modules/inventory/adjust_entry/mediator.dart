import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/custom_listviews/inventory_movement_product_list_view.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';

class AdjustEntryHeaderData {
  String? branchId;
  String? description;
  // docNumber is usually auto-generated or optional input, user said "no external doc number",
  // but let's keep a field if they want to specify internal ref or just description.
  // User said "solo que aca siempre no hay un proveedor tampoco un numero de factura, pero si va la fecha y la descripcion."
  // So: Date (maybe auto or selectable), Description.
  // Branch is implicit or selectable.
  DateTime? docDate;

  bool hasNullFields() {
    // If description is mandatory? Maybe not. Branch is usually current, but let's ensure.
    // Let's assume description is optional but Date is required.
    return docDate == null;
  }

  void clear() {
    description = null;
    docDate = DateTime.now();
  }
}

class AdjustEntryNotifier extends ChangeNotifier {
  final ProductTableController _productTableController = ProductTableController();
  final ProductListViewController _productListViewController = ProductListViewController();
  final AdjustEntryHeaderData _headerData = AdjustEntryHeaderData()..docDate = DateTime.now();

  ProductTableController get productTableController => _productTableController;
  ProductListViewController get productListViewController => _productListViewController;
  AdjustEntryHeaderData get headerData => _headerData;

  bool hasProductWithZeroValue() {
    final rows = _productTableController.rows;
    for (var row in rows) {
      if (row.quantity == 0 || row.unitaryCost == 0) return true;
    }
    return false;
  }

  bool hasMobileProductWithZeroValue() {
    final rows = _productListViewController.rowCards;
    for (var row in rows) {
      if (row.quantity == 0 || row.unitaryCost == 0) return true;
    }
    return false;
  }

  void refresh() => notifyListeners();
}

class AdjustEntryMediator extends InheritedNotifier<AdjustEntryNotifier> {
  const AdjustEntryMediator({super.key, required super.child, super.notifier});

  AdjustEntryHeaderData get headerData => notifier!.headerData;
  ProductTableController get productTableController => notifier!.productTableController;
  ProductListViewController get productListViewController => notifier!.productListViewController;

  bool hasAllRequiredFields() => ![headerData.hasNullFields(), productTableController.rows.isEmpty].contains(true);

  bool hasMobileAllRequiredFields() => ![
    headerData.hasNullFields(),
    productListViewController.rowCards.isEmpty,
  ].contains(true);

  bool hasProductWithZeroValue() => notifier!.hasProductWithZeroValue();
  bool hasMobileProductWithZeroValue() => notifier!.hasMobileProductWithZeroValue();

  int get total => productTableController.total;

  void refresh() => notifier!.refresh();

  static AdjustEntryMediator? read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AdjustEntryMediator>();
    return element?.widget as AdjustEntryMediator?;
  }

  static AdjustEntryMediator? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdjustEntryMediator>()!;
}
