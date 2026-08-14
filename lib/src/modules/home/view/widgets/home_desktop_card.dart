import 'package:flutter/material.dart';

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
    final effectiveColor = widget.accentColor ?? Colors.indigo;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? effectiveColor.withValues(alpha: 0.45)
                : Colors.grey.shade200,
            width: _isHovered ? 1.3 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? effectiveColor.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 16 : 6,
              offset: _isHovered ? const Offset(0, 6) : const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      color: effectiveColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _isHovered ? effectiveColor : Colors.black87,
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
                    duration: const Duration(milliseconds: 180),
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
                      size: 20,
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
