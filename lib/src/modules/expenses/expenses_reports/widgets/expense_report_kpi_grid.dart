import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_aggregation.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Grid de indicadores principales del reporte de gastos.
class ExpenseReportKpiGrid extends StatelessWidget {
  const ExpenseReportKpiGrid({super.key, required this.items});

  final List<ExpenseInDb> items;

  @override
  Widget build(BuildContext context) {
    final metrics = ExpenseMetrics.fromExpenses(items);
    final typeTotals = summarizeExpenseTypes(items);

    var cancelledAmount = 0;
    var cancelledCount = 0;
    for (final expense in items) {
      if (expense.isDeleted || expense.status != ExpenseStatus.cancelled) continue;
      cancelledAmount += expense.amount;
      cancelledCount++;
    }

    final cards = <_KpiData>[
      _KpiData(
        label: 'Total registrado',
        amount: metrics.total,
        caption: _plural(metrics.count, 'registro', 'registros'),
        icon: Icons.account_balance_wallet_rounded,
        color: AppThemeTokens.indigo,
      ),
      _KpiData(
        label: 'Operativos',
        amount: typeTotals.operative,
        caption: _plural(typeTotals.operativeCount, 'registro', 'registros'),
        icon: Icons.business_center_rounded,
        color: AppThemeTokens.info,
      ),
      _KpiData(
        label: 'Proveedores',
        amount: typeTotals.supplier,
        caption: _plural(typeTotals.supplierCount, 'registro', 'registros'),
        icon: Icons.local_shipping_rounded,
        color: AppThemeTokens.teal,
      ),
      if (typeTotals.tax > 0)
        _KpiData(
          label: 'Impuestos',
          amount: typeTotals.tax,
          caption: _plural(typeTotals.taxCount, 'registro', 'registros'),
          icon: Icons.receipt_long_rounded,
          color: AppThemeTokens.purple,
        ),
      _KpiData(
        label: 'Pagado',
        amount: metrics.paid,
        caption: _plural(metrics.paidCount, 'pagado', 'pagados'),
        icon: Icons.check_circle_outline_rounded,
        color: AppThemeTokens.success,
      ),
      _KpiData(
        label: 'Pendiente',
        amount: metrics.pending,
        caption: _plural(metrics.pendingCount, 'pendiente', 'pendientes'),
        icon: Icons.schedule_rounded,
        color: AppThemeTokens.warning,
      ),
      _KpiData(
        label: 'Vencidos',
        amount: metrics.overdueAmount,
        caption: _plural(metrics.overdueCount, 'vencido', 'vencidos'),
        icon: Icons.warning_amber_rounded,
        color: AppThemeTokens.danger,
      ),
      if (cancelledCount > 0)
        _KpiData(
          label: 'Cancelados',
          amount: cancelledAmount,
          caption: _plural(cancelledCount, 'cancelado', 'cancelados'),
          icon: Icons.cancel_outlined,
          color: AppThemeTokens.neutral,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1180
            ? 3
            : width >= 620
            ? 2
            : 1;
        const spacing = 12.0;
        final cardWidth = columns == 1 ? width : (width - spacing * (columns - 1)) / columns;

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
                    child: _KpiCard(data: card),
                  ),
              ],
            ),
            if (metrics.count > 0) ...[
              const SizedBox(height: 7),
              Text(
                'Montos calculados sobre ${metrics.count} registros del período.',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
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

class _KpiData {
  const _KpiData({
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
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: AppThemeTokens.borderRadiusSm,
              border: Border.all(color: data.color.withValues(alpha: 0.22)),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  NumberFormatter.convertToMoneyLike(data.amount),
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
                  data.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
