import 'package:flutter/material.dart';
import 'app_theme_tokens.dart';

enum AppBadgeVariant {
  success,
  warning,
  danger,
  info,
  purple,
  indigo,
  teal,
  neutral,
}

/// Badge compacto y estandarizado tipo píldora (Modern SaaS Pill Badge).
class AppStatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final AppBadgeVariant? variant;
  final bool isFilled;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.variant,
    this.isFilled = false,
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
  });

  // Constructores fábrica convenientes
  factory AppStatusBadge.success({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.success);

  factory AppStatusBadge.warning({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.warning);

  factory AppStatusBadge.danger({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.danger);

  factory AppStatusBadge.info({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.info);

  factory AppStatusBadge.purple({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.purple);

  factory AppStatusBadge.indigo({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.indigo);

  factory AppStatusBadge.teal({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.teal);

  factory AppStatusBadge.neutral({required String label, IconData? icon}) =>
      AppStatusBadge(label: label, icon: icon, variant: AppBadgeVariant.neutral);

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    switch (variant ?? AppBadgeVariant.neutral) {
      case AppBadgeVariant.success:
        return AppThemeTokens.success;
      case AppBadgeVariant.warning:
        return AppThemeTokens.warning;
      case AppBadgeVariant.danger:
        return AppThemeTokens.danger;
      case AppBadgeVariant.info:
        return AppThemeTokens.info;
      case AppBadgeVariant.purple:
        return AppThemeTokens.purple;
      case AppBadgeVariant.indigo:
        return AppThemeTokens.indigo;
      case AppBadgeVariant.teal:
        return AppThemeTokens.teal;
      case AppBadgeVariant.neutral:
        return AppThemeTokens.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _resolveColor(context);

    final bg = isFilled
        ? baseColor
        : baseColor.withValues(alpha: 0.12);

    final textAndIconColor = isFilled
        ? Colors.white
        : baseColor;

    final borderColor = isFilled
        ? Colors.transparent
        : baseColor.withValues(alpha: 0.28);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 1.5,
              color: textAndIconColor,
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textAndIconColor,
              letterSpacing: -0.1,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
