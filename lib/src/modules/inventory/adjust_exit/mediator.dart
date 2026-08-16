import 'package:flutter/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'view_controller.dart';

class AdjustExitMediator extends InheritedNotifier<AdjustExitViewController> {
  const AdjustExitMediator({
    super.key,
    required super.child,
    required AdjustExitViewController viewController,
  }) : super(notifier: viewController);

  AdjustExitViewController get viewController => notifier!;
  AdjustExitType get type => viewController.type;

  static AdjustExitMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdjustExitMediator>()!;
  }

  static AdjustExitViewController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AdjustExitMediator>();
    return (element?.widget as AdjustExitMediator).viewController;
  }

  static AdjustExitViewController watch(BuildContext context) {
    return of(context).viewController;
  }
}
