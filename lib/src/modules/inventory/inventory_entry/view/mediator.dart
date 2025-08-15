import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
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
      'docDate': docDate?.toIso8601String(),
      'observations': observations,
    };
  }

  bool hasNullFields() => [supplier, docNumber, docDate].contains(null);

  void clear() {
    supplier = null;
    docNumber = null;
    docDate = null;
    observations = null;
  }
}

class InventoryEntryNotifier extends ChangeNotifier {
  final ProductTableController controller = ProductTableController();
  final HeaderData headerData = HeaderData();

  bool hasProductWithZeroValue() {
    final rows = controller.rows;
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
  ProductTableController get productTableController => notifier!.controller;

  bool hasAllRequiredFields() => ![headerData.hasNullFields(), productTableController.rows.isEmpty].contains(true);

  bool hasProductWithZeroValue() => notifier!.hasProductWithZeroValue();

  void refresh() => notifier!.refresh();

  static InventoryEntryMediator? read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryEntryMediator>();
    return element?.widget as InventoryEntryMediator?;
  }

  static InventoryEntryMediator? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InventoryEntryMediator>()!;
}
