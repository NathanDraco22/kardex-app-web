import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';

import 'components/totals_summary_view.dart';
import 'components/cash_flow_view.dart';

class DailyOperationsResultsScreenWeb extends StatefulWidget {
  const DailyOperationsResultsScreenWeb({super.key});

  @override
  State<DailyOperationsResultsScreenWeb> createState() => _DailyOperationsResultsScreenWebState();
}

class _DailyOperationsResultsScreenWebState extends State<DailyOperationsResultsScreenWeb> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          currentIndex: _currentIndex,
          onIndexChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        Expanded(
          child: BlocBuilder<ReadReportsCubit, ReadReportsState>(
            builder: (context, state) {
              if (state is ReadReportsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReadReportsError) {
                return Center(child: Text(state.message));
              }

              if (state is ReadReportsSuccess) {
                if (_currentIndex == 0) {
                  return TotalsSummaryView(result: state.result);
                } else {
                  return CashFlowView(result: state.result);
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

class _Header extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const _Header({
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadReportsCubit>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 250,
                child: DatePickerButton(
                  title: "Fecha",
                  defaultDate: cubit.startDate,
                  onSelected: (date) {
                    cubit.startDate = date;
                    cubit.endDate = date;
                    cubit.loadReports();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text("Resumen General"),
                  icon: Icon(Icons.dashboard),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text("Arqueo de Efectivo"),
                  icon: Icon(Icons.attach_money),
                ),
              ],
              selected: {currentIndex},
              onSelectionChanged: (Set<int> newSelection) {
                onIndexChanged(newSelection.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}
