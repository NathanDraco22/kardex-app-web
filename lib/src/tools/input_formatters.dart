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

class DoubleThousandsFormatter extends TextInputFormatter {
  final int decimalDigits;

  DoubleThousandsFormatter({this.decimalDigits = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Si se borra el texto, permite que el campo quede vacío.
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Limpia el texto para procesarlo, quitando las comas.
    String text = newValue.text.replaceAll(',', '');

    // Permite solo números y un punto decimal.
    final regExp = RegExp(r'^\d*\.?\d*$');
    if (!regExp.hasMatch(text)) {
      return oldValue;
    }

    List<String> parts = text.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Formatea la parte entera con comas.
    if (integerPart.isNotEmpty) {
      final number = int.parse(integerPart);
      final formatter = NumberFormat("#,###");
      integerPart = formatter.format(number);
    }

    // Limita la longitud de la parte decimal.
    if (decimalPart.length > decimalDigits) {
      decimalPart = decimalPart.substring(0, decimalDigits);
    }

    // Reconstruye el texto.
    String newText;
    if (parts.length > 1) {
      newText = '$integerPart.$decimalPart';
    } else {
      newText = integerPart;
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
