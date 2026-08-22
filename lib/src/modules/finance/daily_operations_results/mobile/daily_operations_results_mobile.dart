import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/finance/daily_operations_results/widgets/widgets.dart';

class DailyOperationsResultsMobile extends StatefulWidget {
  const DailyOperationsResultsMobile({super.key});

  @override
  State<DailyOperationsResultsMobile> createState() => _DailyOperationsResultsMobileState();
}

class _DailyOperationsResultsMobileState extends State<DailyOperationsResultsMobile> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DailyOperationsFilterBar(
          currentIndex: _currentIndex,
          onIndexChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          mode: DailyOperationsFilterBarMode.mobile,
        ),
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
                if (_currentIndex == 0) {
                  return SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      children: [
                        DailyInvoicesTotalsCard(result: result),
                        const SizedBox(height: 14),
                        DailyReceiptsTotalsCard(result: result),
                        const SizedBox(height: 14),
                        DailyCashFlowTotalsCard(result: result),
                        const SizedBox(height: 48),
                      ],
                    ),
                  );
                } else {
                  return DailyCashFlowArqueoView(result: result);
                }
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
