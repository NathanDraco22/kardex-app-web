import 'package:flutter/material.dart';

/// Tarjeta moderna para opciones de submenú móvil.
///
/// Diseñada con estética consistente a `DesktopSubmenuCard`: fondo blanco,
/// esquinas redondeadas (14 dp), borde sutil, icono centrado en contenedor
/// redondeado tintado con el color temático de la herramienta, título en
/// negrita, subtítulo explicativo y chevron de navegación.
class MenuOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const MenuOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.onTap,
    this.trailing,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        accentColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: effectiveColor.withValues(alpha: 0.08),
          highlightColor: effectiveColor.withValues(alpha: 0.04),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade400,
                      size: 22,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
