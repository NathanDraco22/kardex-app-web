import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_business/kardex_business.dart';

import 'components/range_totals_summary_view.dart';

class RangeFinanceReportScreenWeb extends StatefulWidget {
  const RangeFinanceReportScreenWeb({super.key});

  @override
  State<RangeFinanceReportScreenWeb> createState() => _RangeFinanceReportScreenWebState();
}

class _RangeFinanceReportScreenWebState extends State<RangeFinanceReportScreenWeb> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadReportsCubit>();
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(4.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DatePickerListTile(
                        key: ValueKey(readCubit.startDate),
                        defaultDate: readCubit.startDate,
                        title: "Fecha Inicio",
                        onSelected: (value) {
                          readCubit.startDate = value;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                      child: VerticalDivider(),
                    ),
                    Expanded(
                      child: DatePickerListTile(
                        key: ValueKey(readCubit.endDate),
                        defaultDate: readCubit.endDate,
                        title: "Fecha Fin",
                        onSelected: (value) {
                          readCubit.endDate = value;
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        readCubit.loadReports(getIt<AuthCubit>().currentBranchId);
                      },
                      label: const Text("Filtrar"),
                      icon: const Icon(Icons.filter_alt_rounded),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        // Limpiar filtros: Regresar al mes actual (del 1 de este mes a hoy)
                        final now = DateTime.now();
                        readCubit.startDate = DateTime(now.year, now.month, 1);
                        readCubit.endDate = DateTimeTool.getTodayMidnight();
                        setState(() {});
                        readCubit.loadReports(getIt<AuthCubit>().currentBranchId);
                      },
                      child: const Icon(Icons.clear),
                    ),
                  ],
                ),
              ],
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
                return RangeTotalsSummaryView(result: state.result);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
