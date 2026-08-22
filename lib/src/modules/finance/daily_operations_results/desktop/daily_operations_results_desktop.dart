import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/finance/daily_operations_results/widgets/widgets.dart';

class DailyOperationsResultsDesktop extends StatefulWidget {
  const DailyOperationsResultsDesktop({super.key});

  @override
  State<DailyOperationsResultsDesktop> createState() => _DailyOperationsResultsDesktopState();
}

class _DailyOperationsResultsDesktopState extends State<DailyOperationsResultsDesktop> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: DailyOperationsFilterBar(
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              mode: DailyOperationsFilterBarMode.desktop,
            ),
          ),
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
                    padding: const EdgeInsets.all(32.0),
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Columna Izquierda: Facturas y Recaudos
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DailyInvoicesTotalsCard(result: result),
                                      const SizedBox(height: 16),
                                      DailyReceiptsTotalsCard(result: result),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Columna Derecha: Flujo de Ingresos
                                Expanded(
                                  flex: 5,
                                  child: DailyCashFlowTotalsCard(result: result),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: DailyCashFlowArqueoView(result: result),
                    ),
                  );
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
