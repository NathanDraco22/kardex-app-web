import 'package:flutter/material.dart';

/// Botón terciario de estilo plano/texto diseñado para barras de menú, barras de herramientas
/// y encabezados como [AppBar] o contenedores con fondo sólido oscuro o claro.
///
/// Comparte la misma silueta de esquinas redondeadas (`BorderRadius.circular(12)`),
/// altura y densidad que [PrimaryMenuButton] y [SecondaryMenuButton], eliminando
/// los márgenes táctiles residuales de Flutter mediante [MaterialTapTargetSize.shrinkWrap]
/// para evitar empujar o desalinear elementos vecinos.
class TertiaryMenuButton extends StatelessWidget {
  const TertiaryMenuButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.tooltip,
    this.focusNode,
  });

  /// Acción a ejecutar al pulsar el botón. Si es `null`, el botón queda inactivo.
  final VoidCallback? onPressed;

  /// Etiqueta o contenido principal del botón (generalmente [Text]).
  final Widget label;

  /// Icono opcional que acompaña a la etiqueta (generalmente [Icon]).
  final Widget? icon;

  /// Color de fondo opcional (por defecto transparente).
  final Color? backgroundColor;

  /// Color de texto e icono personalizado.
  /// Si se omite, toma el color del tema o del contexto (p. ej. [AppBarTheme.foregroundColor] o [ColorScheme.primary]).
  final Color? foregroundColor;

  /// Relleno interno del botón. Por defecto `symmetric(horizontal: 14, vertical: 10)`.
  final EdgeInsetsGeometry? padding;

  /// Mensaje descriptivo mostrado en tooltip si se provee.
  final String? tooltip;

  /// Nodo de foco opcional.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = TextButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );

    Widget button;
    if (icon != null) {
      button = TextButton.icon(
        focusNode: focusNode,
        onPressed: onPressed,
        icon: icon!,
        label: label,
        style: effectiveStyle,
      );
    } else {
      button = TextButton(
        focusNode: focusNode,
        onPressed: onPressed,
        style: effectiveStyle,
        child: label,
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
