import 'package:flutter/material.dart';
import '../view_controller.dart';

class InventoryExitMediator extends InheritedNotifier<InventoryExitViewController> {
  const InventoryExitMediator({
    super.key,
    required super.child,
    required InventoryExitViewController viewController,
  }) : super(notifier: viewController);

  InventoryExitViewController get viewController => notifier!;

  static InventoryExitMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InventoryExitMediator>()!;
  }

  static InventoryExitViewController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<InventoryExitMediator>();
    return (element?.widget as InventoryExitMediator).viewController;
  }

  static InventoryExitViewController watch(BuildContext context) {
    return of(context).viewController;
  }
}
