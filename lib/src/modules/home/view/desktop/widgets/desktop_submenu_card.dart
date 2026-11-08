import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/home/data/home_modules_registry.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';

class DesktopSubmenuCard extends StatefulWidget {
  final HomeSubmoduleItem item;
  final Color accentColor;
  final VoidCallback onTap;

  const DesktopSubmenuCard({
    super.key,
    required this.item,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<DesktopSubmenuCard> createState() => _DesktopSubmenuCardState();
}

class _DesktopSubmenuCardState extends State<DesktopSubmenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.item.accentColor ?? widget.accentColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(
              color: _isHovered
                  ? effectiveColor.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered
                ? AppThemeTokens.hoverCardShadow(accent: effectiveColor)
                : AppThemeTokens.subtleCardShadow(accent: effectiveColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: AppThemeTokens.borderRadiusMd,
              splashColor: effectiveColor.withValues(alpha: 0.08),
              highlightColor: effectiveColor.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? effectiveColor.withValues(alpha: 0.16)
                            : effectiveColor.withValues(alpha: 0.09),
                        borderRadius: AppThemeTokens.borderRadiusSm,
                        border: Border.all(
                          color: effectiveColor.withValues(alpha: _isHovered ? 0.35 : 0.18),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: effectiveColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: _isHovered ? effectiveColor : const Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.item.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.item.subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      transform: Matrix4.translationValues(
                        _isHovered ? 3.0 : 0.0,
                        0.0,
                        0.0,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _isHovered
                            ? effectiveColor
                            : const Color(0xFF94A3B8),
                        size: 19,
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
