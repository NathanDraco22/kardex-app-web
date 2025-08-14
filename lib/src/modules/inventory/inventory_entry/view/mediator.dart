import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';

class InventoryEntryNotifier extends ChangeNotifier {
  final ProductTableController controller = ProductTableController();
}

class InventoryEntryMediator extends InheritedNotifier<InventoryEntryNotifier> {
  const InventoryEntryMediator({super.key, required super.child, super.notifier});

  static InventoryEntryMediator? of(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryEntryMediator>();
    return element?.widget as InventoryEntryMediator?;
  }
}
