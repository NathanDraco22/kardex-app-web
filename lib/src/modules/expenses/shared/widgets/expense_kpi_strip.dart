import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Barra compacta con los montos principales de la lista de gastos.
///
/// Sustituye a las tarjetas KPI grandes para que el header y los filtros
/// ocupen poco espacio vertical. En desktop se muestra en una fila y en
/// móvil/tablet en una grilla de dos columnas.
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
        final isWide = constraints.maxWidth >= 760;
        final metricsWidget = isWide
            ? Row(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const _MetricDivider(),
                    Expanded(child: _CompactMetric(data: items[index])),
                  ],
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _CompactMetric(data: items[0])),
                      const SizedBox(width: 12),
                      Expanded(child: _CompactMetric(data: items[1])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _CompactMetric(data: items[2])),
                      const SizedBox(width: 12),
                      Expanded(child: _CompactMetric(data: items[3])),
                    ],
                  ),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            metricsWidget,
            if (totalLoaded > 0) ...[
              const SizedBox(height: 5),
              Text(
                'Montos sobre ${metrics.count} registros visibles de $totalLoaded cargados.',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
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
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.10),
            borderRadius: AppThemeTokens.borderRadiusSm,
          ),
          child: Icon(data.icon, size: 14, color: data.color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                NumberFormatter.convertToMoneyLike(data.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              Text(
                '${data.count} ${data.count == 1 ? 'registro' : 'registros'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppThemeTokens.borderLight,
    );
  }
}
