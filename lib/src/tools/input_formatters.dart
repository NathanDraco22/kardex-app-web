import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

class IntegerThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Si el nuevo valor está vacío, no hagas nada
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limpia el texto de cualquier caracter que no sea un dígito
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Convierte el texto limpio a un número
    final number = int.parse(newText);

    // Usa NumberFormat para añadir las comas
    final formatter = NumberFormat("#,###");
    final formattedText = formatter.format(number);

    // Devuelve el nuevo valor formateado y ajusta la posición del cursor
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
