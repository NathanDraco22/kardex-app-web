import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';

class SaleTerminalMobileMediator extends InheritedWidget {
  const SaleTerminalMobileMediator({
    super.key,
    required this.viewController,
    required super.child,
  });

  final SaleTerminalViewController viewController;

  static SaleTerminalMobileMediator of(BuildContext context) {
    final SaleTerminalMobileMediator? result =
        context.dependOnInheritedWidgetOfExactType<SaleTerminalMobileMediator>();
    assert(result != null, 'No SaleTerminalMobileMediator found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SaleTerminalMobileMediator oldWidget) {
    return viewController != oldWidget.viewController;
  }
}
