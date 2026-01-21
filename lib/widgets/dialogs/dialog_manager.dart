import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

class DialogManager {
  static Future<void> showErrorDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          icon: Icon(
            Icons.error,
            color: Colors.red.shade300,
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => context.pop(),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showInfoDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          icon: Icon(
            Icons.info,
            color: Colors.blue.shade300,
          ),
          actions: [
            TextButton(
              autofocus: true,
              child: const Text('OK'),
              onPressed: () => context.pop(),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> confirmActionDialog(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Accion'),
          content: Text(message),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade300),
              child: const Text('Cancelar'),
              onPressed: () => context.pop(false),
            ),
            TextButton(
              autofocus: true,
              style: TextButton.styleFrom(foregroundColor: Colors.green.shade300),
              child: const Text('Aceptar'),
              onPressed: () => context.pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<bool> slideToConfirmDeleteActionDialog(BuildContext context, String message) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          content: CustomSlider(
            hintText: "Desliza para eliminar",
            hintIcon: Icons.delete,
            sliderColor: Colors.red.shade300,
            sliderText: "Eliminar",
            onSubmit: () => context.pop(true),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  static Future<bool> slideToConfirmActionDialog(BuildContext context, String message) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          content: CustomSlider(
            hintText: "Desliza para guardar",
            hintIcon: Icons.save,
            sliderColor: Colors.green.shade300,
            sliderText: "Guardar",
            onSubmit: () => context.pop(true),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
