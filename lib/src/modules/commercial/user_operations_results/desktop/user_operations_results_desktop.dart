import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/user_reports/read_user_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/user_operations_results/widgets/widgets.dart';

class UserOperationsResultsDesktop extends StatefulWidget {
  const UserOperationsResultsDesktop({super.key});

  @override
  State<UserOperationsResultsDesktop> createState() => _UserOperationsResultsDesktopState();
}

class _UserOperationsResultsDesktopState extends State<UserOperationsResultsDesktop> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: UserOperationsFilterBar(
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              mode: UserOperationsFilterBarMode.desktop,
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ReadUserReportsCubit, ReadUserReportsState>(
            builder: (context, state) {
              if (state is ReadUserReportsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReadUserReportsError) {
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

              if (state is ReadUserReportsSuccess) {
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
                                      UserInvoicesTotalsCard(result: result, showProfit: false),
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
