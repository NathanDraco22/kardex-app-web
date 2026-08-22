import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/cubit/read_admin_range_finance_report_cubit.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/widgets/widgets.dart';

class AdminRangeFinanceReportDesktop extends StatelessWidget {
  const AdminRangeFinanceReportDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: const RangeFinanceFilterBar(isCompact: false),
          ),
        ),
        Expanded(
          child: BlocBuilder<ReadAdminRangeFinanceReportCubit, ReadAdminRangeFinanceReportState>(
            builder: (context, state) {
              if (state is ReadAdminRangeFinanceReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReadAdminRangeFinanceReportError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (state is ReadAdminRangeFinanceReportSuccess) {
                final summary = state.summary;
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
