import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';

class SaleTerminalWebMediator extends InheritedWidget {
  const SaleTerminalWebMediator({
    super.key,
    required super.child,
    required this.viewController,
  });

  final SaleTerminalViewController viewController;

  static SaleTerminalWebMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SaleTerminalWebMediator>()!;
  }

  @override
  bool updateShouldNotify(SaleTerminalWebMediator oldWidget) {
    return false;
  }
}
