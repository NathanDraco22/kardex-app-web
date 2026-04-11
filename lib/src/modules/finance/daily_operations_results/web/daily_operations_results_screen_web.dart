import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';

import 'components/totals_summary_view.dart';

class DailyOperationsResultsScreenWeb extends StatelessWidget {
  const DailyOperationsResultsScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(),
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
                return TotalsSummaryView(result: state.result);
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadReportsCubit>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DatePickerButton(
            title: "Fecha",
            defaultDate: cubit.startDate,
            onSelected: (date) {
              cubit.startDate = date;
              cubit.endDate = date;
              cubit.loadReports();
            },
          ),
        ],
      ),
    );
  }
}
