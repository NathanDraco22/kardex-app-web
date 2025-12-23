import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/daily_summary/cubit/read_daily_summary_cubit.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/daily_summary/daily_summary_detail_screen.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dailySummariesRepository = context.read<DailySummariesRepository>();
    return BlocProvider(
      create: (context) => ReadDailySummaryCubit(
        dailySummariesRepository: dailySummariesRepository,
      )..getDailySummary(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resumen Diario"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadDailySummaryCubit, ReadDailySummaryState>(
      builder: (context, state) {
        if (state is ReadDailySummaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReadDailySummaryFailure) {
          return Center(child: Text("Error: ${state.message}"));
        }

        if (state is ReadDailySummarySuccess) {
          if (state.dailySummaries.isEmpty) {
            return const Center(child: Text("No hay datos disponibles"));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (state is! ReadFetchingMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                context.read<ReadDailySummaryCubit>().getNextPage();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: state.dailySummaries.length + (state is ReadFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < state.dailySummaries.length) {
                  final summary = state.dailySummaries[index];
                  return ListTile(
                    title: Text(
                      "Fecha: ${DateTimeTool.formatddMM(DateTime.fromMillisecondsSinceEpoch(summary.startDate))}",
                    ),
                    subtitle: Text("Total: ${NumberFormatter.convertToMoneyLike(summary.total)}"),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DailySummaryDetailScreen(summary: summary),
                        ),
                      );
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
