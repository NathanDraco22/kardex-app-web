import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/cubit/read_admin_range_finance_report_cubit.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/widgets/widgets.dart';

class AdminRangeFinanceReportTablet extends StatelessWidget {
  const AdminRangeFinanceReportTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RangeFinanceFilterBar(isCompact: false),
        Expanded(
          child: BlocBuilder<ReadAdminRangeFinanceReportCubit, ReadAdminRangeFinanceReportState>(
            builder: (context, state) {
              if (state is ReadAdminRangeFinanceReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReadAdminRangeFinanceReportError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
