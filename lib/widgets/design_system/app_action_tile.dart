import 'package:flutter/material.dart';

import 'app_theme_tokens.dart';

/// Tile de acción reutilizable para menús y paneles.
///
/// Mantiene el lenguaje visual suave del resto de la app: fondo blanco,
/// borde neutro, sombras discretas y el acento reservado para el icono,
/// el hover y el chevron de navegación.
class AppActionTile extends StatefulWidget {
  const AppActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.accentColor = AppThemeTokens.indigo,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accentColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<AppActionTile> createState() => _AppActionTileState();
}

class _AppActionTileState extends State<AppActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final isInteractive = widget.onTap != null;
    final isHighlighted = _isHovered && isInteractive;

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: isHighlighted ? 1.006 : 1.0,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 84),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlighted ? accent.withValues(alpha: 0.30) : AppThemeTokens.borderLight,
              width: isHighlighted ? 1.2 : 1.0,
            ),
            boxShadow: isHighlighted
                ? AppThemeTokens.hoverCardShadow(accent: accent)
                : AppThemeTokens.subtleCardShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: accent.withValues(alpha: 0.08),
              highlightColor: accent.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isHighlighted ? 0.12 : 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accent.withValues(alpha: isHighlighted ? 0.24 : 0.14),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: accent,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (widget.subtitle != null && widget.subtitle!.trim().isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.3,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    widget.trailing ??
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 170),
                          transform: Matrix4.translationValues(isHighlighted ? 3.0 : 0.0, 0.0, 0.0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: isHighlighted ? accent : const Color(0xFF94A3B8),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
