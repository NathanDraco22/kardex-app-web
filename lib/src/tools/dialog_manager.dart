import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_to_submit_button/slide_to_submit_button.dart';

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
          content: SizedBox(
            width: 200,
            child: SlideToSubmit.custom(
              hint: Align(
                alignment: Alignment.centerRight,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.grey.shade200,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Desliza para confirmar",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              slider: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.red.shade300,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              backgroundDecoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              sliderWidth: 120,
              height: 60,
              onSubmit: (controller) {
                context.pop(true);
              },
              threshold: 0.95,
            ),
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
