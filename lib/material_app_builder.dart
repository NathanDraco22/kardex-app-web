import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/app_router.dart';
import 'package:kardex_app_front/cubits/app_mode/app_mode_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/spotlight_calculator.dart';

class OpenCalculatorIntent extends Intent {
  const OpenCalculatorIntent();
}

Widget materialAppBuilder(BuildContext context, Widget? child) {
  final mediaQueryData = MediaQuery.of(context);
  final systemTextScalerFactor = mediaQueryData.textScaler;

  Widget childWidget = child!;

  final appModeCubit = context.read<AppModeCubit>();
  if (appModeCubit.state is PracticeModeState) {
    childWidget = Stack(
      children: [
        child,
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(90),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Modo Practica",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Envolver la navegación en los atajos globales de teclado (ej. Ctrl + Espacio)
  childWidget = Shortcuts(
    shortcuts: <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.space, control: true): const OpenCalculatorIntent(),
    },
    child: Actions(
      actions: <Type, Action<Intent>>{
        OpenCalculatorIntent: CallbackAction<OpenCalculatorIntent>(
          onInvoke: (intent) {
            final navContext = rootNavigatorKey.currentContext;
            if (navContext != null) {
              showSpotlightCalculator(navContext);
            }
            return null;
          },
        ),
      },
      child: childWidget,
    ),
  );

  return MediaQuery(
    data: mediaQueryData.copyWith(
      textScaler: systemTextScalerFactor.clamp(
        minScaleFactor: 0.8,
        maxScaleFactor: 1.2,
      ),
    ),
    child: childWidget,
  );
}
