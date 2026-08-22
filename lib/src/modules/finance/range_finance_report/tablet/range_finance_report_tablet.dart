import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/finance/range_finance_report/widgets/widgets.dart';

class RangeFinanceReportTablet extends StatelessWidget {
  const RangeFinanceReportTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BranchRangeFilterBar(isCompact: false),
        Expanded(
          child: BlocBuilder<ReadReportsCubit, ReadReportsState>(
            builder: (context, state) {
              if (state is ReadReportsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReadReportsError) {
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

              if (state is ReadReportsSuccess) {
                final result = state.result;
                return SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Columna Izquierda: Ventas y Crédito
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BranchSalesTotalsCard(result: result),
                                const SizedBox(height: 16),
                                BranchCreditControlCard(result: result),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Columna Derecha: Flujo de Caja y Abonos
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BranchCashFlowTotalsCard(result: result),
                                const SizedBox(height: 16),
                                BranchReceiptsTotalsCard(result: result),
                              ],
                            ),
                          ),
                        ],
                      ),
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
