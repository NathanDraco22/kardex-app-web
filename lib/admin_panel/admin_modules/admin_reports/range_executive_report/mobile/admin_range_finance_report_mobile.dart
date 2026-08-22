import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/cubit/read_admin_range_finance_report_cubit.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/widgets/widgets.dart';

class AdminRangeFinanceReportMobile extends StatelessWidget {
  const AdminRangeFinanceReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RangeFinanceFilterBar(isCompact: true),
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
                return SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    children: [
                      SalesSummaryCard(summary: summary),
                      if (summary.commercialBranches.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SalesPieChartCard(summary: summary),
                      ],
                      const SizedBox(height: 16),
                      CashFlowSummaryCard(summary: summary),
                      if (summary.commercialBranches.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        CashFlowChartCard(summary: summary),
                      ],
                      const SizedBox(height: 16),
                      ExpensesSummaryCard(summary: summary),
                      if (summary.commercialBranches.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ExpensesPieChartCard(summary: summary),
                      ],
                      const SizedBox(height: 16),
                      OtherStatsCard(summary: summary),
                      if (summary.inventoryBranches.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InventoryPieChartCard(summary: summary),
                      ],
                      if (summary.totalPendingBranches.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        DebtPieChartCard(summary: summary),
                      ],
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
