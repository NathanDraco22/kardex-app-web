import 'package:flutter/material.dart';
import 'view_controller.dart';

class AdjustEntryMediator extends InheritedNotifier<AdjustEntryViewController> {
  const AdjustEntryMediator({
    super.key,
    required super.child,
    required AdjustEntryViewController viewController,
  }) : super(notifier: viewController);

  AdjustEntryViewController get viewController => notifier!;

  static AdjustEntryMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdjustEntryMediator>()!;
  }

  static AdjustEntryViewController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AdjustEntryMediator>();
    return (element?.widget as AdjustEntryMediator).viewController;
  }

  static AdjustEntryViewController watch(BuildContext context) {
    return of(context).viewController;
  }
}
