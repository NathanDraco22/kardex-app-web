import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

/// Muestra un visor de documento de forma adaptativa según el tamaño de pantalla:
/// - En escritorio (`>= 840 dp`), se presenta como modal bottom sheet centrado
///   con un ancho máximo de [maxWidth] y una altura del [desktopHeightFactor].
/// - En móvil o tablet (`< 840 dp`), navega a pantalla completa con [MaterialPageRoute].
Future<T?> showAdaptiveViewer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 600,
  double desktopHeightFactor = 0.95,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  if (context.isDesktop()) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: maxWidth),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * desktopHeightFactor;
        return SizedBox(
          height: maxHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: EscapeToCloseWrapper(
              child: builder(sheetContext),
            ),
          ),
        );
      },
    );
  }

  return Navigator.push<T>(
    context,
    MaterialPageRoute<T>(
      builder: (routeContext) => EscapeToCloseWrapper(
        child: builder(routeContext),
      ),
    ),
  );
}

/// Envuelve un visor para cerrarlo al presionar la tecla `Escape`.
class EscapeToCloseWrapper extends StatelessWidget {
  const EscapeToCloseWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).maybePop();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
