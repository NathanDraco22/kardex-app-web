import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

Future<bool?> showConfirmationSendBottomModal(
  BuildContext context, {
  required String title,
  required String subtitle,
  Widget? content,
}) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.65,
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
        title: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: CustomSlider(
            hintText: "Desliza para Enviar",
            hintIcon: Icons.save,
            sliderColor: Colors.green,
            sliderText: "Enviar",
            onSubmit: () {
              Navigator.pop(context, true);
            },
          ),
        ),
      ),
      body: content,
    );
  }
}
