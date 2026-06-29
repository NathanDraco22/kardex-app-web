import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

Future<bool?> showConfirmationBottomModal(
  BuildContext context, {
  required String title,
  required String subtitle,
  Widget? content,
}) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    builder: (context) {
      return ConfirmationSaveModal(
        title: title,
        subtitle: subtitle,
        content: content,
      );
    },
  );
}

class ConfirmationSaveModal extends StatelessWidget {
  const ConfirmationSaveModal({
    super.key,
    required this.title,
    required this.subtitle,
    this.content,
  });

  final String title;
  final String subtitle;

  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(Icons.close),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Guardar Documento?"),
            Text("(No se puede deshacer)", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: CustomSlider(
          hintText: "Desliza para guardar",
          hintIcon: Icons.save,
          sliderColor: Colors.green,
          sliderText: "Guardar",
          onSubmit: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: content,
    );
  }
}
