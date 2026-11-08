import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';

class HomeDesktopOptionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback onTap;

  const HomeDesktopOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    required this.onTap,
  });

  @override
  State<HomeDesktopOptionCard> createState() => _HomeDesktopOptionCardState();
}

class _HomeDesktopOptionCardState extends State<HomeDesktopOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.accentColor ?? AppThemeTokens.indigo;

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
            borderRadius: AppThemeTokens.borderRadiusLg,
            border: Border.all(
              color: _isHovered
                  ? effectiveColor.withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.3 : 1.0,
            ),
            boxShadow: _isHovered
                ? AppThemeTokens.hoverCardShadow(accent: effectiveColor)
                : AppThemeTokens.subtleCardShadow(accent: effectiveColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: AppThemeTokens.borderRadiusLg,
              splashColor: effectiveColor.withValues(alpha: 0.1),
              highlightColor: effectiveColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? effectiveColor.withValues(alpha: 0.18)
                            : effectiveColor.withValues(alpha: 0.10),
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        border: Border.all(
                          color: effectiveColor.withValues(alpha: _isHovered ? 0.35 : 0.18),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: effectiveColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: _isHovered ? effectiveColor : const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 12.5,
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
                        _isHovered ? 4.0 : 0.0,
                        0.0,
                        0.0,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _isHovered
                            ? effectiveColor
                            : const Color(0xFF94A3B8),
                        size: 20,
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
