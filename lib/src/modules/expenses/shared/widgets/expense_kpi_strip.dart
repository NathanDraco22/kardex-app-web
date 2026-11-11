import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Barra ultra compacta con los montos principales de la lista de gastos.
///
/// Diseñada para ocupar la mínima altura vertical sin tarjetas pesadas,
/// mostrando chips estilizados en una sola línea o wrap responsivo.
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
    final items = <_MetricData>[
      _MetricData(
        label: 'Total',
        amount: metrics.total,
        count: metrics.count,
        icon: Icons.account_balance_wallet_rounded,
        color: accentColor,
      ),
      _MetricData(
        label: 'Pagado',
        amount: metrics.paid,
        count: metrics.paidCount,
        icon: Icons.check_circle_outline_rounded,
        color: AppThemeTokens.success,
      ),
      _MetricData(
        label: 'Pendiente',
        amount: metrics.pending,
        count: metrics.pendingCount,
        icon: Icons.schedule_rounded,
        color: AppThemeTokens.warning,
      ),
      _MetricData(
        label: 'Vencidos',
        amount: metrics.overdueAmount,
        count: metrics.overdueCount,
        icon: Icons.warning_amber_rounded,
        color: AppThemeTokens.danger,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final metricsWidget = isWide
            ? Row(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(child: _CompactMetric(data: items[index])),
                  ],
                ],
              )
            : Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final item in items) _CompactMetric(data: item),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            metricsWidget,
            if (totalLoaded > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Montos sobre ${metrics.count} registros visibles de $totalLoaded cargados.',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.amount,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int amount;
  final int count;
  final IconData icon;
  final Color color;
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.07),
        borderRadius: AppThemeTokens.borderRadiusSm,
        border: Border.all(
          color: data.color.withValues(alpha: 0.20),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${data.label}: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              height: 1.0,
            ),
          ),
          Flexible(
            child: Text(
              NumberFormatter.convertToMoneyLike(data.amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${data.count})',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
