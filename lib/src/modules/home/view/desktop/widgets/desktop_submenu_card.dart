import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/home/data/home_modules_registry.dart';

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? effectiveColor.withValues(alpha: 0.45)
                : Colors.grey.shade200,
            width: _isHovered ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? effectiveColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.015),
              blurRadius: _isHovered ? 12 : 5,
              offset: _isHovered ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: effectiveColor.withValues(alpha: 0.08),
            highlightColor: effectiveColor.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? effectiveColor.withValues(alpha: 0.16)
                          : effectiveColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.item.icon,
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
                          widget.item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isHovered ? effectiveColor : Colors.black87,
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
                              fontSize: 11.5,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    transform: Matrix4.translationValues(
                      _isHovered ? 2.0 : 0.0,
                      0.0,
                      0.0,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _isHovered
                          ? effectiveColor
                          : Colors.grey.shade300,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
