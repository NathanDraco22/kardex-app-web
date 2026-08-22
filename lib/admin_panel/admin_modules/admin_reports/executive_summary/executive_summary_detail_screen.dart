import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/widgets/widgets.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';

class ExecutiveSummaryDetailScreen extends StatelessWidget {
  const ExecutiveSummaryDetailScreen({super.key, required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resumen Ejecutivo: ${DateTimeTool.formatddMM(
            DateTime.fromMillisecondsSinceEpoch(summary.startDate),
          )}",
        ),
      ),
      body: _Body(summary: summary),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop()) {
      return _ExecutiveSummaryDesktop(summary: summary);
    }

    if (context.isTablet()) {
      return _ExecutiveSummaryTablet(summary: summary);
    }

    return _ExecutiveSummaryMobile(summary: summary);
  }
}

class _ExecutiveSummaryMobile extends StatelessWidget {
  const _ExecutiveSummaryMobile({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final hasCommercial = summary.commercialBranches.isNotEmpty;
    final hasInventory = summary.inventoryBranches.isNotEmpty;
    final hasDebt = summary.totalPendingBranches.isNotEmpty;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        children: [
          SalesSummaryCard(summary: summary),
          if (hasCommercial) ...[
            const SizedBox(height: 8),
            SalesPieChartCard(summary: summary),
          ],
          const SizedBox(height: 16),
          CashFlowSummaryCard(summary: summary),
          if (hasCommercial) ...[
            const SizedBox(height: 8),
            CashFlowChartCard(summary: summary),
          ],
          const SizedBox(height: 16),
          ExpensesSummaryCard(summary: summary),
          if (hasCommercial) ...[
            const SizedBox(height: 8),
            ExpensesPieChartCard(summary: summary),
          ],
          const SizedBox(height: 16),
          OtherStatsCard(summary: summary),
          if (hasInventory) ...[
            const SizedBox(height: 8),
            InventoryPieChartCard(summary: summary),
          ],
          if (hasDebt) ...[
            const SizedBox(height: 8),
            DebtPieChartCard(summary: summary),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ExecutiveSummaryTablet extends StatelessWidget {
  const _ExecutiveSummaryTablet({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final hasCommercial = summary.commercialBranches.isNotEmpty;
    final hasInventory = summary.inventoryBranches.isNotEmpty;
    final hasDebt = summary.totalPendingBranches.isNotEmpty;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Ventas
          if (hasCommercial)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SalesSummaryCard(summary: summary)),
                const SizedBox(width: 12),
                Expanded(child: SalesPieChartCard(summary: summary)),
              ],
            )
          else
            SalesSummaryCard(summary: summary),
          const SizedBox(height: 16),

          // Flujo de Caja
          if (hasCommercial)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CashFlowSummaryCard(summary: summary)),
                const SizedBox(width: 12),
                Expanded(child: CashFlowChartCard(summary: summary)),
              ],
            )
          else
            CashFlowSummaryCard(summary: summary),
          const SizedBox(height: 16),

          // Gastos
          if (hasCommercial)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ExpensesSummaryCard(summary: summary)),
                const SizedBox(width: 12),
                Expanded(child: ExpensesPieChartCard(summary: summary)),
              ],
            )
          else
            ExpensesSummaryCard(summary: summary),
          const SizedBox(height: 16),

          // Balance y Otros Datos
          if (hasInventory || hasDebt)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: OtherStatsCard(summary: summary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasInventory) InventoryPieChartCard(summary: summary),
                      if (hasInventory && hasDebt) const SizedBox(height: 12),
                      if (hasDebt) DebtPieChartCard(summary: summary),
                    ],
                  ),
                ),
              ],
            )
          else
            OtherStatsCard(summary: summary),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ExecutiveSummaryDesktop extends StatelessWidget {
  const _ExecutiveSummaryDesktop({required this.summary});

  final ExecutiveSummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final hasCommercial = summary.commercialBranches.isNotEmpty;
    final hasInventory = summary.inventoryBranches.isNotEmpty;
    final hasDebt = summary.totalPendingBranches.isNotEmpty;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Sección 1: Ventas y Rentabilidad
              if (hasCommercial)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: SalesSummaryCard(summary: summary)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: SalesPieChartCard(summary: summary)),
                  ],
                )
              else
                SalesSummaryCard(summary: summary),
              const SizedBox(height: 20),

              // Sección 2: Flujo de Caja
              if (hasCommercial)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: CashFlowSummaryCard(summary: summary)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: CashFlowChartCard(summary: summary)),
                  ],
                )
              else
                CashFlowSummaryCard(summary: summary),
              const SizedBox(height: 20),

              // Sección 3: Gastos y Egresos Operativos
              if (hasCommercial)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: ExpensesSummaryCard(summary: summary)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: ExpensesPieChartCard(summary: summary)),
                  ],
                )
              else
                ExpensesSummaryCard(summary: summary),
              const SizedBox(height: 20),

              // Sección 4: Otros Datos, Inventario y CxC
              if (hasInventory || hasDebt)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: OtherStatsCard(summary: summary),
                    ),
                    if (hasInventory) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: InventoryPieChartCard(summary: summary),
                      ),
                    ],
                    if (hasDebt) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: DebtPieChartCard(summary: summary),
                      ),
                    ],
                  ],
                )
              else
                OtherStatsCard(summary: summary),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
