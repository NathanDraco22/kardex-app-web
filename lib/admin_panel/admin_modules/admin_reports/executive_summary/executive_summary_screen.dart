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

                  final ganancia = summary.salesTotal - summary.salesTotalCost;
                  final isProfit = ganancia >= 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExecutiveSummaryDetailScreen(summary: summary),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary.type.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_long, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${summary.totalInvoices} fact",
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  NumberFormatter.convertToMoneyLike(summary.salesTotal),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isProfit
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    NumberFormatter.convertToMoneyLike(ganancia),
                                    style: TextStyle(
                                      color: isProfit ? Colors.green[700] : Colors.red[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
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
