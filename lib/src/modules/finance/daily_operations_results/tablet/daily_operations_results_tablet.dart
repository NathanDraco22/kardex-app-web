import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/finance/daily_operations_results/widgets/widgets.dart';

class DailyOperationsResultsTablet extends StatefulWidget {
  const DailyOperationsResultsTablet({super.key});

  @override
  State<DailyOperationsResultsTablet> createState() => _DailyOperationsResultsTabletState();
}

class _DailyOperationsResultsTabletState extends State<DailyOperationsResultsTablet> {
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
          mode: DailyOperationsFilterBarMode.tablet,
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Columna Izquierda: Facturas y Recaudos
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DailyInvoicesTotalsCard(result: result),
                                  const SizedBox(height: 14),
                                  DailyReceiptsTotalsCard(result: result),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Columna Derecha: Flujo de Ingresos
                            Expanded(
                              child: DailyCashFlowTotalsCard(result: result),
                            ),
                          ],
                        ),
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
