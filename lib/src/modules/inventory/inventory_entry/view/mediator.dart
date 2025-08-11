import 'package:flutter/material.dart';

class InventoryEntryMediator extends InheritedWidget {
  InventoryEntryMediator({super.key, required super.child});

  final SharedNotifiers sharedNotifiers = SharedNotifiers();

  static InventoryEntryMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InventoryEntryMediator>()!;
  }

  @override
  bool updateShouldNotify(InventoryEntryMediator oldWidget) {
    return false;
  }
}

class SharedNotifiers {
  final ValueNotifier<int> totalNotifier = ValueNotifier(0);
}
