import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Franja de 4 tarjetas KPI con los montos principales de la lista de gastos.
class ExpenseKpiStrip extends StatelessWidget {
  const ExpenseKpiStrip({
    super.key,
    required this.metrics,
    required this.accentColor,
    required this.totalLoaded,
  });

  final ExpenseMetrics metrics;
  final Color accentColor;

  /// Registros cargados desde el servidor; contextualiza el alcance de los KPIs.
  final int totalLoaded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1040
            ? 4
            : width >= 600
            ? 2
            : 1;
        const spacing = 12.0;
        final cardWidth = columns == 1 ? width : (width - spacing * (columns - 1)) / columns;

        final cards = [
          _KpiCard(
            label: 'Total registrado',
            amount: metrics.total,
            caption: _plural(metrics.count, 'registro', 'registros'),
            icon: Icons.account_balance_wallet_rounded,
            color: accentColor,
          ),
          _KpiCard(
            label: 'Pagado',
            amount: metrics.paid,
            caption: _plural(metrics.paidCount, 'pagado', 'pagados'),
            icon: Icons.check_circle_outline_rounded,
            color: AppThemeTokens.success,
          ),
          _KpiCard(
            label: 'Pendiente',
            amount: metrics.pending,
            caption: _plural(metrics.pendingCount, 'pendiente', 'pendientes'),
            icon: Icons.schedule_rounded,
            color: AppThemeTokens.warning,
          ),
          _KpiCard(
            label: 'Vencidos',
            amount: metrics.overdueAmount,
            caption: _plural(metrics.overdueCount, 'vencido', 'vencidos'),
            icon: Icons.warning_amber_rounded,
            color: AppThemeTokens.danger,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: cardWidth,
                    child: card,
                  ),
              ],
            ),
            if (totalLoaded > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Montos sobre ${metrics.count} registros visibles de $totalLoaded cargados.',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _plural(int value, String singular, String plural) {
    return '$value ${value == 1 ? singular : plural}';
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.amount,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final int amount;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormatter.convertToMoneyLike(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
