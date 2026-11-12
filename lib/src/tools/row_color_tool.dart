import 'package:flutter/material.dart';

/// Utilidades de color para filas de tablas y listas.
class RowColorTool {
  RowColorTool._();

  /// Color de fondo alternado (cebra) para filas de tablas y listas.
  ///
  /// Índices pares usan gris claro y los impares blanco.
  static Color getRowColor(int index) {
    return index.isOdd ? Colors.white : Colors.grey.shade200;
  }
}
