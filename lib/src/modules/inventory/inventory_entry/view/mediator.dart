import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/widgets/custom_listviews/inventory_movement_product_list_view.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';

class HeaderData {
  SupplierInDb? supplier;
  String? docNumber;
  DateTime? docDate;
  String? observations;

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplier?.id,
      'docNumber': docNumber,
      'docDate': docDate?.millisecondsSinceEpoch,
      'observations': observations,
    };
  }

  bool hasNullFields() {
    final fields = [supplier, docNumber, docDate];
    return fields.contains(null) ||
        fields.any(
          (element) {
            if (element is String) return element.isEmpty;
            return false;
          },
        );
  }

  void clear() {
    supplier = null;
    docNumber = null;
    docDate = null;
    observations = null;
  }
}

class InventoryEntryNotifier extends ChangeNotifier {
  final ProductTableController controllerTable = ProductTableController();
  final ProductListViewController controllerListView = ProductListViewController();
  final HeaderData headerData = HeaderData();

  bool hasProductWithZeroValue() {
    final rows = controllerTable.rows;
    for (var row in rows) {
      if (row.quantity == 0 || row.unitaryCost == 0) return true;
    }
    return false;
  }

  bool hasMobileProductWithZeroValue() {
    final rows = controllerListView.rowCards;
    for (var row in rows) {
      if (row.quantity == 0 || row.unitaryCost == 0) return true;
    }
    return false;
  }

  void refresh() => notifyListeners();
}

class InventoryEntryMediator extends InheritedNotifier<InventoryEntryNotifier> {
  const InventoryEntryMediator({super.key, required super.child, super.notifier});

  HeaderData get headerData => notifier!.headerData;
  ProductTableController get productTableController => notifier!.controllerTable;
  ProductListViewController get productListViewController => notifier!.controllerListView;

  bool hasAllRequiredFields() => ![headerData.hasNullFields(), productTableController.rows.isEmpty].contains(true);

  bool hasProductWithZeroValue() => notifier!.hasProductWithZeroValue();

  bool hasMobileAllRequiredFields() => ![
    headerData.hasNullFields(),
    productListViewController.rowCards.isEmpty,
  ].contains(true);

  bool hasMobileProductWithZeroValue() => notifier!.hasMobileProductWithZeroValue();

  int get productCount => productTableController.rows.length;
  int get mobileProductCount => productListViewController.rowCards.length;

  int get total => productTableController.total;
  int get mobileTotal => productListViewController.total;

  void refresh() => notifier!.refresh();

  static InventoryEntryMediator? read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryEntryMediator>();
    return element?.widget as InventoryEntryMediator?;
  }

  static InventoryEntryMediator? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InventoryEntryMediator>()!;
}
