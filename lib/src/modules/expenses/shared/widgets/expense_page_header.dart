import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Encabezado principal de una lista de gastos.
///
/// Contiene el icono tintado, el título, el subtítulo, el refresco y la acción
/// primaria para crear un gasto.
class ExpensePageHeader extends StatelessWidget {
  const ExpensePageHeader({
    super.key,
    required this.config,
    required this.onRefresh,
    required this.onCreate,
    this.isRefreshing = false,
  });

  final ExpenseListConfig config;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        final titleBlock = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: config.accentColor.withValues(alpha: 0.12),
                borderRadius: AppThemeTokens.borderRadiusMd,
                border: Border.all(color: config.accentColor.withValues(alpha: 0.24)),
              ),
              child: Icon(
                config.icon,
                color: config.accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _RefreshButton(
              accentColor: config.accentColor,
              isRefreshing: isRefreshing,
              onPressed: onRefresh,
            ),
            PrimaryMenuButton(
              onPressed: onCreate,
              backgroundColor: config.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                config.createButtonLabel,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: actions,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({
    required this.accentColor,
    required this.isRefreshing,
    required this.onPressed,
  });

  final Color accentColor;
  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Actualizar',
      child: Material(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusMd,
        child: InkWell(
          onTap: isRefreshing ? null : onPressed,
          borderRadius: AppThemeTokens.borderRadiusMd,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: AppThemeTokens.borderLight),
            ),
            child: Center(
              child: isRefreshing
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      size: 21,
                      color: Color(0xFF475569),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
