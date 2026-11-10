import 'package:flutter/material.dart';

/// Muestra el nombre de la unidad seleccionada y resalta las unidades
/// distintas a la base. No muestra el factor crudo para evitar ruido.
class UnitDisplayer extends StatelessWidget {
  const UnitDisplayer({
    super.key,
    required this.unitName,
    required this.conversionFactor,
    this.fallbackUnitName = '',
    this.style,
    this.highlightStyle,
    this.textAlign,
    this.prefix = '',
    this.suffix = '',
  });

  final String unitName;
  final int conversionFactor;
  final String fallbackUnitName;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final TextAlign? textAlign;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final resolvedName = unitName.isNotEmpty ? unitName : fallbackUnitName;
    final isSecondaryUnit = conversionFactor > 1;
    final displayText = "$prefix$resolvedName$suffix";

    final effectiveStyle = isSecondaryUnit
        ? (highlightStyle ??
              style?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue) ??
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
        : style;

    return Text(
      displayText,
      textAlign: textAlign,
      style: effectiveStyle,
    );
  }
}
