import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/admin_panel/widgets/custom_7_bar_chart.dart';
import 'package:kardex_app_front/admin_panel/widgets/custom_7_charts.dart';
import 'package:kardex_app_front/admin_panel/widgets/title_amount.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/src/cubits/finance/read_finance_charts_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class FinancesMenuScreen extends StatelessWidget {
  const FinancesMenuScreen({super.key});

  static const accessName = Modules.finance;

  @override
  Widget build(BuildContext context) {
    final adminPanelRepo = context.read<AdminPanelRepository>();
    return BlocProvider(
      create: (context) => ReadFinanceChartsCubit(adminPanelRepo)..getCharts(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finanzas")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadFinanceChartsCubit>().state;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          children: [
            if (state is ReadFinanceChartsLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is ReadFinanceChartsFailure)
              Center(child: Text(state.message))
            else if (state is ReadFinanceChartsSuccess) ...[
              _ChartsCard(state: state),
              const SizedBox(height: 12),
            ],
            const Divider(height: 0.0),
            ListTile(
              leading: const Icon(
                FluentIcons.notepad_person_24_filled,
                color: Colors.blue,
              ),
              title: const Text("Estado de cuenta de Clientes"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed("client-accounts"),
            ),
            const Divider(height: 0.0),
            ListTile(
              leading: const Icon(
                FluentIcons.receipt_money_24_filled,
                color: Colors.green,
              ),
              title: const Text("Facturas Liquidadas"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed("paid-invoices"),
            ),
            const Divider(height: 0.0),
          ],
        ),
      ),
    );
  }
}

class _ChartsCard extends StatelessWidget {
  const _ChartsCard({required this.state});

  final ReadFinanceChartsSuccess state;

  @override
  Widget build(BuildContext context) {
    final charts = state.charts;
    final yesterdayTotal = charts.last7DaysTotals.last;
    final last7DaysTotalAmount = charts.last7DaysTotals.fold(
      0,
      (previousValue, element) => previousValue + element.total,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              padding: const EdgeInsets.all(8),
              child: Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleAmount(
                    title: "Ventas Ayer",
                    amount: NumberFormatter.convertToMoneyLike(yesterdayTotal.total),
                  ),
                ],
              ),
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                TitleAmount(
                  title: "Ultimos 7 dias",
                  amount: NumberFormatter.convertToMoneyLike(last7DaysTotalAmount),
                ),
                Custom7DaysBarChart(
                  data: List.generate(
                    charts.last7DaysTotals.length,
                    (index) => CustomChartData(
                      value: NumberFormatter.convertFromCentsToDouble(charts.last7DaysTotals[index].total),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
