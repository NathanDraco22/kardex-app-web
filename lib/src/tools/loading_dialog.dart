import 'package:flutter/material.dart';

class LoadingDialogManager {
  static bool isLoading = false;

  static Future<void> showLoadingDialog(BuildContext context) async {
    isLoading = true;
    await showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    isLoading = false;
  }

  static void closeLoadingDialog(BuildContext context) {
    if (isLoading) {
      Navigator.of(context).pop();
    }
  }
}
