import 'package:flutter/material.dart';

/// Botón primario diseñado para barras de menú, filtros y encabezados.
///
/// Por defecto usa el color primario del tema con texto `onPrimary`. Aplica un
/// borde suavemente redondeado (`BorderRadius.circular(12)`), elimina márgenes
/// residuales táctiles con [MaterialTapTargetSize.shrinkWrap] y utiliza un
/// relleno compacto para alinearse con otros controles.
class PrimaryMenuButton extends StatelessWidget {
  const PrimaryMenuButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
  });

  /// Acción a ejecutar al pulsar el botón. Si es `null`, el botón queda inactivo.
  final VoidCallback? onPressed;

  /// Etiqueta o contenido principal del botón (generalmente [Text]).
  final Widget label;

  /// Icono opcional que acompaña a la etiqueta (generalmente [Icon]).
  final Widget? icon;

  /// Color de fondo personalizado. Si se omite, usa `colorScheme.primary`.
  final Color? backgroundColor;

  /// Color de texto e icono personalizado. Si se omite, usa `colorScheme.onPrimary`.
  final Color? foregroundColor;

  /// Relleno interno del botón. Por defecto `symmetric(horizontal: 14, vertical: 10)`.
  final EdgeInsetsGeometry? padding;

  /// Mensaje descriptivo mostrado en tooltip si se provee.
  final String? tooltip;

  /// Nodo de foco opcional.
  final FocusNode? focusNode;

  /// Si el botón debe recibir el foco automáticamente. Por defecto `false`.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final effectiveStyle = FilledButton.styleFrom(
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );

    Widget button;
    if (icon != null) {
      button = FilledButton.icon(
        focusNode: focusNode,
        autofocus: autofocus,
        onPressed: onPressed,
        icon: icon!,
        label: label,
        style: effectiveStyle,
      );
    } else {
      button = FilledButton(
        focusNode: focusNode,
        autofocus: autofocus,
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
