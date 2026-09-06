import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/user_reports/read_user_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/user_operations_results/widgets/widgets.dart';

class UserOperationsResultsTablet extends StatefulWidget {
  const UserOperationsResultsTablet({super.key});

  @override
  State<UserOperationsResultsTablet> createState() => _UserOperationsResultsTabletState();
}

class _UserOperationsResultsTabletState extends State<UserOperationsResultsTablet> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserOperationsFilterBar(
          currentIndex: _currentIndex,
          onIndexChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          mode: UserOperationsFilterBarMode.tablet,
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
                    padding: const EdgeInsets.all(24.0),
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
                                  UserInvoicesTotalsCard(result: result, showProfit: false),
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
