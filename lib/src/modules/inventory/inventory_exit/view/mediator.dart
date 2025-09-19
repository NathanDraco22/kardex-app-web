import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/widgets/custom_listviews/inventory_movement_product_list_view.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';

class ExitHeaderData {
  ClientInDb? client;
  String? docNumber;
  DateTime? docDate;
  String? observations;

  Map<String, dynamic> toJson() {
    return {
      'supplierId': client?.id,
      'docNumber': docNumber,
      'docDate': docDate?.millisecondsSinceEpoch,
      'observations': observations,
    };
  }

  bool hasNullFields() {
    final fields = [client, docNumber, docDate];
    return fields.contains(null) ||
        fields.any(
          (element) {
            if (element is String) return element.isEmpty;
            return false;
          },
        );
  }

  void clear() {
    client = null;
    docNumber = null;
    docDate = null;
    observations = null;
  }
}

class InventoryExitNotifier extends ChangeNotifier {
  final ProductTableController controller = ProductTableController();
  final ProductListViewController controllerListView = ProductListViewController();
  final ExitHeaderData headerData = ExitHeaderData();

  bool hasProductWithZeroValue() {
    final rows = controller.rows;
    for (var row in rows) {
      if (row.quantity == 0) return true;
    }
    return false;
  }

  bool hasMobileProductWithZeroValue() {
    final rows = controllerListView.rowCards;
    for (var row in rows) {
      if (row.quantity == 0) return true;
    }
    return false;
  }

  void refresh() => notifyListeners();
}

class InventoryExitMediator extends InheritedNotifier<InventoryExitNotifier> {
  const InventoryExitMediator({super.key, required super.child, super.notifier});

  ExitHeaderData get headerData => notifier!.headerData;
  ProductTableController get productTableController => notifier!.controller;
  ProductListViewController get productListViewController => notifier!.controllerListView;

  bool hasAllRequiredFields() => ![headerData.hasNullFields(), productTableController.rows.isEmpty].contains(true);

  bool hasProductWithZeroValue() => notifier!.hasProductWithZeroValue();

  bool hasMobileAllRequiredFields() => ![
    headerData.hasNullFields(),
    productListViewController.rowCards.isEmpty,
  ].contains(true);

  bool hasMobileProductWithZeroValue() => notifier!.hasMobileProductWithZeroValue();

  void refresh() => notifier!.refresh();

  static InventoryExitMediator? read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryExitMediator>();
    return element?.widget as InventoryExitMediator?;
  }

  static InventoryExitMediator? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InventoryExitMediator>()!;
}
