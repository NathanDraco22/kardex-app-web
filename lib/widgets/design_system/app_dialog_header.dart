import 'package:flutter/material.dart';
import 'app_theme_tokens.dart';

/// Encabezado moderno para modales y diálogos interactivos (Modern Modal Header).
class AppDialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final Widget? trailingBadge;
  final VoidCallback? onClose;

  const AppDialogHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.trailingBadge,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Icono en caja suave
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.12),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(
                color: effectiveColor.withValues(alpha: 0.22),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailingBadge != null) ...[
                      const SizedBox(width: 8),
                      trailingBadge!,
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: Colors.grey.shade500,
              splashRadius: 20,
              tooltip: "Cerrar",
              onPressed: onClose,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
