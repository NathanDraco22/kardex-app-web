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
}

class InventoryEntryNotifier extends ChangeNotifier {
  final ProductTableController controller = ProductTableController();
  final HeaderData headerData = HeaderData();
}

class InventoryEntryMediator extends InheritedNotifier<InventoryEntryNotifier> {
  const InventoryEntryMediator({super.key, required super.child, super.notifier});

  HeaderData get headerData => notifier!.headerData;
  ProductTableController get productTableController => notifier!.controller;

  static InventoryEntryMediator? of(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryEntryMediator>();
    return element?.widget as InventoryEntryMediator?;
  }
}
