import 'package:flutter/material.dart';

/// Botón secundario con contorno (outline) diseñado para barras de menú, filtros y encabezados.
///
/// Comparte la misma silueta, radio suave (`BorderRadius.circular(12)`), altura y densidad
/// que [PrimaryMenuButton], eliminando márgenes residuales tácitos para mantener
/// una alineación limpia y homogénea entre botones adyacentes.
class SecondaryMenuButton extends StatelessWidget {
  const SecondaryMenuButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.borderColor,
    this.borderOpacity,
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

  /// Color del borde. Si se omite, usa `colorScheme.outline` con opacidad suave [borderOpacity].
  final Color? borderColor;

  /// Opacidad aplicada al borde del botón por defecto (0.25 para un trazo sutil).
  final double? borderOpacity;

  /// Color de fondo opcional (por defecto transparente o definido por el tema).
  final Color? backgroundColor;

  /// Color de texto e icono personalizado. Si se omite, usa `colorScheme.primary`.
  final Color? foregroundColor;

  /// Relleno interno del botón. Por defecto `symmetric(horizontal: 14, vertical: 10)`.
  final EdgeInsetsGeometry? padding;

  /// Mensaje descriptivo mostrado en tooltip si se provee.
  final String? tooltip;

  /// Nodo de foco opcional.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final opacity = borderOpacity ?? 0.25;
    final effectiveStyle = OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      side: BorderSide(
        color: borderColor ?? Theme.of(context).colorScheme.outline.withValues(alpha: opacity),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );

    Widget button;
    if (icon != null) {
      button = OutlinedButton.icon(
        focusNode: focusNode,
        onPressed: onPressed,
        icon: icon!,
        label: label,
        style: effectiveStyle,
      );
    } else {
      button = OutlinedButton(
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
