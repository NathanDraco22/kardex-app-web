import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_aggregation.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/tools/color_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Color estable de una fila del consolidado según su etiqueta.
///
/// "Otros" siempre usa el gris neutro para no competir con los grupos reales.
Color expenseBreakdownColor(String label) {
  if (label == 'Otros') return AppThemeTokens.neutral;

  final palette = ColorTool.getChartColors();
  var hash = 0;
  for (final codeUnit in label.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}

/// Consolidado del reporte: total, donas y rankings por categoría/proveedor.
class ExpenseReportConsolidatedView extends StatelessWidget {
  const ExpenseReportConsolidatedView({super.key, required this.items});

  final List<ExpenseInDb> items;

  @override
  Widget build(BuildContext context) {
    final metrics = ExpenseMetrics.fromExpenses(items);
    final typeTotals = summarizeExpenseTypes(items);
    final operativeBreakdown = buildExpenseBreakdown(
      items,
      dimension: ExpenseBreakdownDimension.operativeCategory,
    );
    final supplierBreakdown = buildExpenseBreakdown(
      items,
      dimension: ExpenseBreakdownDimension.supplier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConsolidatedHero(total: metrics.total, count: metrics.count),
        if (typeTotals.tax > 0) ...[
          const SizedBox(height: 8),
          _TaxIncludedNotice(
            amount: typeTotals.tax,
            count: typeTotals.taxCount,
          ),
        ],
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = <Widget>[
              _ExpenseBreakdownCard(
                title: 'Operativos por categoría',
                subtitle: _plural(
                  operativeBreakdown.groupCount,
                  'categoría',
                  'categorías',
                ),
                breakdown: operativeBreakdown,
                icon: Icons.business_center_rounded,
                accentColor: AppThemeTokens.indigo,
                emptyTitle: 'Sin gastos operativos',
                emptySubtitle: 'Los gastos operativos aparecerán aquí agrupados por categoría.',
              ),
              _ExpenseBreakdownCard(
                title: 'Proveedores por proveedor',
                subtitle: _plural(
                  supplierBreakdown.groupCount,
                  'proveedor',
                  'proveedores',
                ),
                breakdown: supplierBreakdown,
                icon: Icons.local_shipping_rounded,
                accentColor: AppThemeTokens.teal,
                emptyTitle: 'Sin gastos a proveedores',
                emptySubtitle: 'Los pagos a proveedores aparecerán aquí agrupados por nombre.',
              ),
            ];

            if (constraints.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[1]),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cards[0],
                const SizedBox(height: 14),
                cards[1],
              ],
            );
          },
        ),
      ],
    );
  }

  String _plural(int value, String singular, String plural) {
    return '$value ${value == 1 ? singular : plural}';
  }
}

class _TaxIncludedNotice extends StatelessWidget {
  const _TaxIncludedNotice({required this.amount, required this.count});

  final int amount;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppThemeTokens.purple.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.purple.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 16,
            color: AppThemeTokens.purple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Impuestos incluidos en el total: '
              '${NumberFormatter.convertToMoneyLike(amount)} '
              '(${count == 1 ? '1 registro' : '$count registros'}).',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsolidatedHero extends StatelessWidget {
  const _ConsolidatedHero({required this.total, required this.count});

  final int total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppThemeTokens.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppThemeTokens.indigo.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total del período',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  NumberFormatter.convertToMoneyLike(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count ${count == 1 ? 'registro' : 'registros'} en el período',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.72),
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

class _ExpenseBreakdownCard extends StatelessWidget {
  const _ExpenseBreakdownCard({
    required this.title,
    required this.subtitle,
    required this.breakdown,
    required this.icon,
    required this.accentColor,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final String title;
  final String subtitle;
  final ExpenseBreakdown breakdown;
  final IconData icon;
  final Color accentColor;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(color: accentColor.withValues(alpha: 0.22)),
                ),
                child: Icon(icon, color: accentColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
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
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  NumberFormatter.convertToMoneyLike(breakdown.total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (breakdown.isEmpty || breakdown.total <= 0)
            AppEmptyState(
              icon: icon,
              title: emptyTitle,
              subtitle: emptySubtitle,
              accentColor: accentColor,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 520;
                final chart = _ExpenseDonut(breakdown: breakdown);
                final legend = _ExpenseLegend(breakdown: breakdown);

                if (!sideBySide) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: 16),
                      legend,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 190, child: chart),
                    const SizedBox(width: 18),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ExpenseDonut extends StatelessWidget {
  const _ExpenseDonut({required this.breakdown});

  final ExpenseBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: 52,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(enabled: false),
              sections: [
                for (var index = 0; index < breakdown.entries.length; index++)
                  PieChartSectionData(
                    value: breakdown.entries[index].amount.toDouble(),
                    color: expenseBreakdownColor(breakdown.entries[index].label),
                    radius: 24,
                    showTitle: breakdown.entries[index].fraction >= 0.09,
                    title: _formatPercent(breakdown.entries[index].fraction),
                    titleStyle: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NumberFormatter.convertToMoneyLike(breakdown.total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseLegend extends StatelessWidget {
  const _ExpenseLegend({required this.breakdown});

  final ExpenseBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < breakdown.entries.length; index++)
          Padding(
            padding: EdgeInsets.only(bottom: index == breakdown.entries.length - 1 ? 0 : 11),
            child: _ExpenseLegendRow(
              entry: breakdown.entries[index],
              color: expenseBreakdownColor(breakdown.entries[index].label),
            ),
          ),
      ],
    );
  }
}

class _ExpenseLegendRow extends StatelessWidget {
  const _ExpenseLegendRow({required this.entry, required this.color});

  final ExpenseBreakdownEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      NumberFormatter.convertToMoneyLike(entry.amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: entry.fraction.clamp(0.0, 1.0),
                        minHeight: 5,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      _formatPercent(entry.fraction),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatPercent(double fraction) {
  final percent = fraction * 100;
  final decimals = percent >= 10 ? 0 : 1;
  return '${percent.toStringAsFixed(decimals)}%';
}
