import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/finance/branch_daily_summary/cubit/read_branch_daily_summary_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class BranchDailySummaryScreen extends StatelessWidget {
  const BranchDailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = context.read<DailySummariesRepository>();
        return ReadBranchDailySummaryCubit(dailySummariesRepository: repo)..getDailySummary();
      },
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

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ReadBranchDailySummaryCubit>().getNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadBranchDailySummaryCubit>().state;

    if (state is ReadBranchDailySummaryInitial || state is ReadBranchDailySummaryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReadBranchDailySummaryFailure) {
      return Center(child: Text("Error: ${state.message}"));
    }

    state as ReadBranchDailySummarySuccess;
    final summaries = state.summaries;

    if (summaries.isEmpty) {
      return const Center(child: Text("No hay datos diarios para tu sucursal."));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ReadBranchDailySummaryCubit>().getDailySummary();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: summaries.length + (state is ReadBranchDailySummaryFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == summaries.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = summaries[index];
          return _SummaryCard(item: item);
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.item,
  });

  final BranchDailySummary item;

  @override
  Widget build(BuildContext context) {
    final detail = item.detail;
    final margin = detail.total - detail.totalCost;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(item.startDate)),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${detail.totalInvoices} facturas",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatColumn(
                  title: "Vendido",
                  amount: detail.total,
                  color: Colors.black87,
                ),
                _StatColumn(
                  title: "Costo",
                  amount: detail.totalCost,
                  color: Colors.red[700]!,
                ),
                _StatColumn(
                  title: "Margen Bruto",
                  amount: margin,
                  color: margin >= 0 ? Colors.green[700]! : Colors.red[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          NumberFormatter.convertToMoneyLike(amount),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
      ],
    );
  }
}
