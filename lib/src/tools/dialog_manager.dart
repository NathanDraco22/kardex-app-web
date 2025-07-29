import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
}
