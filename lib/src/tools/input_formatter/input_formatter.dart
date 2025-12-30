import 'package:flutter/services.dart';

class MonthYearInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Limpia el texto para quedarnos solo con los dígitos
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limita la entrada a un máximo de 4 dígitos (MMYY)
    if (newText.length > 4) {
      return oldValue;
    }

    // --- VALIDACIÓN DEL MES AÑADIDA ---
    if (newText.length >= 2) {
      final month = int.parse(newText.substring(0, 2));
      // Si el mes es inválido (ej. 00, 13, 20), rechaza el cambio.
      if (month < 1 || month > 12) {
        return oldValue;
      }
    }

    String formattedText = newText;
    // Inserta la barra '/' después de los dos primeros dígitos
    if (newText.length > 2) {
      formattedText = '${newText.substring(0, 2)}/${newText.substring(2)}';
    }

    // Calcula la nueva posición del cursor
    int selectionIndex = newValue.selection.end + (formattedText.length - newValue.text.length);
    selectionIndex = selectionIndex.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
