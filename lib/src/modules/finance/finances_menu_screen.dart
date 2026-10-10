import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/admin_panel/widgets/custom_7_bar_chart.dart';
import 'package:kardex_app_front/admin_panel/widgets/custom_7_charts.dart';
import 'package:kardex_app_front/admin_panel/widgets/title_amount.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/finance/read_finance_charts_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';

class FinancesMenuScreen extends StatelessWidget {
  const FinancesMenuScreen({super.key});

  static final accessName = Modules.finance.name;

  @override
  Widget build(BuildContext context) {
    final adminPanelRepo = context.read<AdminPanelRepository>();
    return BlocProvider(
      create: (context) {
        return ReadFinanceChartsCubit(adminPanelRepo)
          ..getChartsCurrentBranch(getIt<AuthCubit>().currentBranchId);
      },
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MenuAppBar(title: "Finanzas"),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadFinanceChartsCubit>().state;
    if (state is ReadFinanceChartsLoading || state is ReadFinanceChartsInitial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state is ReadFinanceChartsFailure) {
      return Center(child: Text(state.message));
    }

    state as ReadFinanceChartsSuccess;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _ChartsCard(state: state),
            const SizedBox(height: 12),
            ShortcutAddableListTile(
              routeName: RouteNames.dailyOperationsResults,
              child: MenuOptionCard(
                icon: Icons.analytics_outlined,
                accentColor: Colors.orange.shade700,
                title: "Resultado de Operaciones Diarias",
                subtitle: "Balance de ingresos y egresos diarios",
                onTap: () => context.pushNamed("daily-operations-results"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.rangeFinanceReport,
              child: MenuOptionCard(
                icon: Icons.date_range_outlined,
                accentColor: Colors.teal.shade600,
                title: "Reporte de Ventas y Flujos",
                subtitle: "Ingresos y egresos en rango de fechas",
                onTap: () => context.pushNamed("finance-range-report"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.clientAccounts,
              child: MenuOptionCard(
                icon: FluentIcons.notepad_person_24_filled,
                accentColor: Colors.blue.shade600,
                title: "Estado de Cuenta de Clientes",
                subtitle: "Extractos detallados y movimientos por cliente",
                onTap: () => context.pushNamed("client-accounts"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.detailInvoiceHistory,
              child: MenuOptionCard(
                icon: Icons.content_paste_search_rounded,
                accentColor: Colors.green.shade600,
                title: "Historial Detallado de Facturas",
                subtitle: "Auditoría integral con condición y pagos",
                onTap: () => context.pushNamed("detail-invoice-history"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.paidInvoices,
              child: MenuOptionCard(
                icon: FluentIcons.receipt_money_24_filled,
                accentColor: Colors.green.shade700,
                title: "Facturas Liquidadas",
                subtitle: "Ventas saldadas en su totalidad",
                onTap: () => context.pushNamed("paid-invoices"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.branchDailySummary,
              child: MenuOptionCard(
                icon: Icons.bar_chart_rounded,
                accentColor: Colors.blue.shade600,
                title: "Resumen Diario",
                subtitle: "Cierre de caja y métricas clave del día",
                onTap: () => context.pushNamed("branch-daily-summary"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.branchExecutiveSummary,
              child: MenuOptionCard(
                icon: Icons.pie_chart_rounded,
                accentColor: Colors.purple.shade600,
                title: "Resumen Ejecutivo",
                subtitle: "Visión panorámica financiera del negocio",
                onTap: () => context.pushNamed("branch-executive-summary"),
              ),
            ),
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
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
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
              spacing: 16,
              children: [
                TitleAmount(
                  title: "Últimos 7 días",
                  amount: NumberFormatter.convertToMoneyLike(last7DaysTotalAmount),
                ),
                Custom7DaysBarChart(
                  data: List.generate(
                    charts.last7DaysTotals.length,
                    (index) => CustomChartData(
                      value: NumberFormatter.convertFromCentsToDouble(
                        charts.last7DaysTotals[index].total,
                      ),
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
