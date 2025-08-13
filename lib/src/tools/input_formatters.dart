import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final regEx = RegExp(r'^\d*\.?\d{0,2}$');
    final String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    if (regEx.hasMatch(newText)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}

class IntegerTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final regEx = RegExp(r'^\d*$');
    final String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    if (regEx.hasMatch(newText)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}
