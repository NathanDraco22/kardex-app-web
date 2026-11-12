import 'package:flutter/material.dart';

import 'view_controller.dart';

class AdjustmentRequestMediator extends InheritedNotifier<AdjustmentRequestViewController> {
  const AdjustmentRequestMediator({
    super.key,
    required super.child,
    required AdjustmentRequestViewController viewController,
  }) : super(notifier: viewController);

  AdjustmentRequestViewController get viewController => notifier!;

  static AdjustmentRequestMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdjustmentRequestMediator>()!;
  }

  static AdjustmentRequestViewController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AdjustmentRequestMediator>();
    return (element?.widget as AdjustmentRequestMediator).viewController;
  }

  static AdjustmentRequestViewController watch(BuildContext context) {
    return of(context).viewController;
  }
}
