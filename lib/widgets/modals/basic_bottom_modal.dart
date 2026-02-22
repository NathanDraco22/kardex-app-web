import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Muestra un modal inferior básico con título, contenido y botones de acción.
Future<bool?> showBasicBottomModal(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget content,
  String acceptText = 'Aceptar',
  String cancelText = 'Cancelar',
  Color? acceptColor,
  Color? cancelColor,
}) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return BasicBottomModal(
        title: title,
        subtitle: subtitle,
        content: content,
        acceptText: acceptText,
        cancelText: cancelText,
        acceptColor: acceptColor,
        cancelColor: cancelColor,
      );
    },
  );
}

class BasicBottomModal extends StatelessWidget {
  const BasicBottomModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.acceptText = 'Aceptar',
    this.cancelText = 'Cancelar',
    this.acceptColor,
    this.cancelColor,
  });

  final String title;
  final String? subtitle;
  final Widget content;
  final String acceptText;
  final String cancelText;
  final Color? acceptColor;
  final Color? cancelColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => context.pop(false),
          icon: const Icon(Icons.close),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cancelColor ?? Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => context.pop(false),
                  child: Text(cancelText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acceptColor ?? Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => context.pop(true),
                  child: Text(
                    acceptText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: content,
    );
  }
}
