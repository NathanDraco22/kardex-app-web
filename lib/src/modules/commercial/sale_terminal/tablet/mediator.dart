import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';

class SaleTerminalTabletMediator extends InheritedWidget {
  const SaleTerminalTabletMediator({
    super.key,
    required super.child,
    required this.viewController,
  });

  final SaleTerminalViewController viewController;

  static SaleTerminalTabletMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SaleTerminalTabletMediator>()!;
  }

  @override
  bool updateShouldNotify(SaleTerminalTabletMediator oldWidget) {
    return false;
  }
}
