import 'package:flutter/material.dart';
import '../view_controller.dart';

class InventoryEntryMediator extends InheritedNotifier<InventoryEntryViewController> {
  const InventoryEntryMediator({
    super.key,
    required super.child,
    required InventoryEntryViewController viewController,
  }) : super(notifier: viewController);

  InventoryEntryViewController get viewController => notifier!;

  static InventoryEntryMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InventoryEntryMediator>()!;
  }

  static InventoryEntryViewController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryEntryMediator>();
    return (element?.widget as InventoryEntryMediator).viewController;
  }

  static InventoryEntryViewController watch(BuildContext context) {
    return of(context).viewController;
  }
}
