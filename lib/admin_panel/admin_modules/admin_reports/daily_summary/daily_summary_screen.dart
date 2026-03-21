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
                  final ganancia = summary.total - summary.totalCost;
                  final isProfit = ganancia >= 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DailySummaryDetailScreen(summary: summary),
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
                                    DateTimeTool.formatdMMeS(DateTime.fromMillisecondsSinceEpoch(summary.startDate)),
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                  NumberFormatter.convertToMoneyLike(summary.total),
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
