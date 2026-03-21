import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/finance/branch_executive_summary/cubit/read_branch_executive_summary_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class BranchExecutiveSummaryScreen extends StatelessWidget {
  const BranchExecutiveSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = context.read<ExecutiveSummariesRepository>();
        return ReadBranchExecutiveSummaryCubit(executiveSummariesRepository: repo)..getExecutiveSummary();
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
        title: const Text("Resumen Ejecutivo"),
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
      context.read<ReadBranchExecutiveSummaryCubit>().getNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadBranchExecutiveSummaryCubit>().state;

    if (state is ReadBranchExecutiveSummaryInitial || state is ReadBranchExecutiveSummaryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReadBranchExecutiveSummaryFailure) {
      return Center(child: Text("Error: ${state.message}"));
    }

    state as ReadBranchExecutiveSummarySuccess;
    final summaries = state.summaries;

    if (summaries.isEmpty) {
      return const Center(child: Text("No hay datos ejecutivos para tu sucursal."));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ReadBranchExecutiveSummaryCubit>().getExecutiveSummary();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: summaries.length + (state is ReadBranchExecutiveSummaryFetchingMore ? 1 : 0),
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

  final BranchExecutiveSummary item;

  @override
  Widget build(BuildContext context) {
    final commercial = item.commercialDetail;
    final inventory = item.inventoryDetail;

    final margin = commercial.total - commercial.totalCost;

    String dateLabel = "";
    if (item.type.name == "monthly") {
      final months = [
        "Enero",
        "Febrero",
        "Marzo",
        "Abril",
        "Mayo",
        "Junio",
        "Julio",
        "Agosto",
        "Septiembre",
        "Octubre",
        "Noviembre",
        "Diciembre",
      ];
      final monthName = (item.month >= 1 && item.month <= 12) ? months[item.month - 1] : "${item.month}";
      dateLabel = "$monthName ${item.year}";
    } else {
      dateLabel = DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(item.startDate));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  "${item.type.label} - $dateLabel",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${commercial.totalInvoices} facturas",
                    style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text(
              "Comercial",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _StatColumn(
                    title: "Ventas",
                    amount: commercial.total,
                    color: Colors.black87,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    title: "Costo Ventas",
                    amount: commercial.totalCost,
                    color: Colors.red[700]!,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    title: "Margen Bruto",
                    amount: margin,
                    color: margin >= 0 ? Colors.green[700]! : Colors.red[700]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _StatColumn(
                    title: "Ventas Contado",
                    amount: commercial.cashSales,
                    color: Colors.green[700]!,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    title: "Recibos",
                    amount: commercial.totalReceiptCash,
                    color: Colors.blue[700]!,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    title: "Devoluciones",
                    amount: commercial.totalReceiptDevolutions,
                    color: Colors.orange[700]!,
                  ),
                ),
              ],
            ),

            if (inventory != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                "Inventario",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatColumn(
                    title: "Valor Inventario",
                    amount: inventory.inventoryTotalCost,
                    color: Colors.blue[800]!,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              "Cuentas por Cobrar",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatColumn(
                  title: "Total Pendiente",
                  amount: commercial.totalOwed,
                  color: Theme.of(context).colorScheme.primary,
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
