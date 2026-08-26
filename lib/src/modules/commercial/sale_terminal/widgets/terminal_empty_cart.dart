import 'package:flutter/material.dart';

/// Widget informativo cuando el carrito de la Terminal de Venta está vacío.
class TerminalEmptyCart extends StatelessWidget {
  const TerminalEmptyCart({
    super.key,
    this.iconSize = 56,
    this.titleFontSize = 16,
    this.subtitleFontSize = 13,
  });

  final double iconSize;
  final double titleFontSize;
  final double subtitleFontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: iconSize,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              "Venta vacía",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Toca un producto para agregarlo",
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
