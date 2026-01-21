import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/executive_summary/cubit/read_executive_summary_cubit.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/executive_summary/executive_summary_detail_screen.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class ExecutiveSummaryScreen extends StatelessWidget {
  const ExecutiveSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final executiveSummariesRepository = context.read<ExecutiveSummariesRepository>();
    return BlocProvider(
      create: (context) => ReadExecutiveSummaryCubit(
        executiveSummariesRepository: executiveSummariesRepository,
      )..getExecutiveSummary(),
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
        title: const Text("Resumen Ejecutivo"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadExecutiveSummaryCubit, ReadExecutiveSummaryState>(
      builder: (context, state) {
        if (state is ReadExecutiveSummaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReadExecutiveSummaryFailure) {
          return Center(child: Text("Error: ${state.message}"));
        }

        if (state is ReadExecutiveSummarySuccess) {
          if (state.executiveSummaries.isEmpty) {
            return const Center(child: Text("No hay datos disponibles"));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (state is! ReadFetchingMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                context.read<ReadExecutiveSummaryCubit>().getNextPage();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: state.executiveSummaries.length + (state is ReadFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < state.executiveSummaries.length) {
                  final summary = state.executiveSummaries[index];
                  final startDate = DateTime.fromMillisecondsSinceEpoch(summary.startDate);
                  final endDate = DateTime.fromMillisecondsSinceEpoch(summary.endDate);
                  String dateText = "${DateTimeTool.formatdMMeS(startDate)} - ${DateTimeTool.formatdMMeS(endDate)}";

                  if (summary.type == .yearly) {
                    dateText = "(${startDate.year})";
                  }
                  if (summary.type == .monthly) {
                    final monthName = DateFormat("MMM", "es").format(startDate);
                    dateText = "$monthName/${startDate.year}";
                  }

                  return ListTile(
                    title: Text(
                      "${summary.type.label}: $dateText",
                    ),
                    subtitle: Text("Ventas: ${NumberFormatter.convertToMoneyLike(summary.salesTotal)}"),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExecutiveSummaryDetailScreen(summary: summary),
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
