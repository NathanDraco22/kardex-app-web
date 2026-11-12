import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_period.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_consolidated.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_detail.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_filters.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_header.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_kpi_grid.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expense_report_view_toggle.dart';
import 'package:kardex_app_front/src/tools/exports/csv_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/expenses_report_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/export_options_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

/// Reporte de gastos responsive.
///
/// Orquesta el período, los KPIs y las vistas de detalle/consolidado. Cada
/// región visual vive en su propio widget bajo `widgets/`.
class ExpensesReportScreen extends StatelessWidget {
  const ExpensesReportScreen({super.key});

  static const int _pageSize = 100;
  static const int _maxPages = 20;

  @override
  Widget build(BuildContext context) {
    final expensesRepository = context.read<ExpensesRepository>();
    final expenseCategoriesRepository = context.read<ExpenseCategoriesRepository>();
    final branchId = getIt<AuthCubit>().currentBranchId;
    final todayRange = rangeFor(ExpenseReportPeriod.today);

    return BlocProvider(
      create: (_) {
        final cubit = ReadExpenseCubit(
          expensesRepository,
          expenseCategoriesRepository,
          branchId: branchId,
        )..queryParams = _queryParams(todayRange, branchId);
        unawaited(cubit.loadAll(maxPages: _maxPages));
        return cubit;
      },
      child: const _ExpensesReportScaffold(),
    );
  }

  static ExpenseQueryParams _queryParams(DateTimeRange range, String? branchId) {
    return ExpenseQueryParams()
      ..branchId = branchId
      ..startDate = range.start.startOfDay().millisecondsSinceEpoch
      ..endDate = range.end.endOfDay().millisecondsSinceEpoch
      ..limit = _pageSize;
  }
}

class _ExpensesReportScaffold extends StatefulWidget {
  const _ExpensesReportScaffold();

  @override
  State<_ExpensesReportScaffold> createState() => _ExpensesReportScaffoldState();
}

class _ExpensesReportScaffoldState extends State<_ExpensesReportScaffold> {
  static const double _desktopBreakpoint = 900;

  ExpenseReportPeriod _period = ExpenseReportPeriod.today;
  DateTimeRange _range = rangeFor(ExpenseReportPeriod.today);
  int _selectedTab = 0;

  Future<void> _reload() async {
    final cubit = context.read<ReadExpenseCubit>();
    cubit.queryParams = ExpensesReportScreen._queryParams(_range, cubit.branchId);
    await cubit.loadAll(maxPages: ExpensesReportScreen._maxPages);
  }

  Future<void> _onPeriodSelected(ExpenseReportPeriod period) async {
    if (period == ExpenseReportPeriod.custom) return;

    setState(() {
      _period = period;
      _range = rangeFor(period);
    });
    await _reload();
  }

  Future<void> _onStartDateChanged(DateTime start) async {
    setState(() {
      _period = ExpenseReportPeriod.custom;
      _range = rangeWithStart(_range, start);
    });
    await _reload();
  }

  Future<void> _onEndDateChanged(DateTime end) async {
    setState(() {
      _period = ExpenseReportPeriod.custom;
      _range = rangeWithEnd(_range, end);
    });
    await _reload();
  }

  Future<void> _clearPeriod() async {
    setState(() {
      _period = ExpenseReportPeriod.today;
      _range = rangeFor(ExpenseReportPeriod.today);
    });
    await _reload();
  }

  Future<void> _export(List<ExpenseInDb> items) async {
    if (items.isEmpty) return;

    final option = await showExportOptionsDialog(context);
    if (option == null || !mounted) return;

    final authCubit = getIt<AuthCubit>();
    final periodText = '${DateTimeTool.formatddMMyyEs(_range.start)}_a_${DateTimeTool.formatddMMyyEs(_range.end)}';

    if (option == ExportOption.csv) {
      await CsvExportTool.exportExpensesToCSV(
        expenses: items,
        fileName: 'reporte_gastos_$periodText',
      );
    } else if (option == ExportOption.pdf) {
      final template = ExpensesReportTemplate(
        title: 'Reporte General de Gastos',
        branchName: authCubit.currentBranchName,
        startDate: _range.start,
        endDate: _range.end,
        items: items,
      );
      await PdfExportTool.export(
        template,
        fileName: 'reporte_gastos_$periodText.pdf',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchName = getIt<AuthCubit>().currentBranchName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Gastos'),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
          builder: (context, state) {
            final successState = state is ReadExpenseSuccess ? state : null;
            final items = successState == null
                ? const <ExpenseInDb>[]
                : successState.items.where((expense) => !expense.isDeleted).toList(growable: false);
            final isRefreshing = state is ReadExpenseSearching || (successState?.isLoadingMore ?? false);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= _desktopBreakpoint;
                final horizontalPadding = isDesktop ? (constraints.maxWidth >= 1280 ? 32.0 : 16.0) : 4.0;
                final topPadding = isDesktop ? 20.0 : 8.0;
                final sectionPadding = isDesktop ? 16.0 : 6.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: RefreshIndicator(
                      color: AppThemeTokens.indigo,
                      onRefresh: _reload,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              topPadding,
                              horizontalPadding,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: ExpenseReportHeader(branchName: branchName),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              sectionPadding,
                              horizontalPadding,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: ExpenseReportFilters(
                                period: _period,
                                startDate: _range.start,
                                endDate: _range.end,
                                onPeriodSelected: _onPeriodSelected,
                                onStartDateChanged: _onStartDateChanged,
                                onEndDateChanged: _onEndDateChanged,
                                onClear: _clearPeriod,
                                onExport: items.isEmpty || isRefreshing ? null : () => _export(items),
                                isRefreshing: isRefreshing,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              10,
                              horizontalPadding,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: SizedBox(
                                height: 2,
                                child: isRefreshing
                                    ? LinearProgressIndicator(
                                        minHeight: 2,
                                        color: AppThemeTokens.indigo,
                                        backgroundColor: AppThemeTokens.indigo.withValues(
                                          alpha: 0.12,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          ..._buildContent(
                            context: context,
                            state: state,
                            successState: successState,
                            items: items,
                            isDesktop: isDesktop,
                            isRefreshing: isRefreshing,
                            horizontalPadding: horizontalPadding,
                          ),
                          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildContent({
    required BuildContext context,
    required ReadExpenseState state,
    required ReadExpenseSuccess? successState,
    required List<ExpenseInDb> items,
    required bool isDesktop,
    required bool isRefreshing,
    required double horizontalPadding,
  }) {
    if (state is ReadExpenseInitial || state is ReadExpenseLoading) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: AppSkeletonLoader.cards(count: 4, padding: EdgeInsets.zero),
          ),
        ),
      ];
    }

    if (state is ReadExpenseError) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudo cargar el reporte',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: _reload,
            ),
          ),
        ),
      ];
    }

    final success = successState!;
    final showLoadNotice = !isRefreshing && (success.hasMore || success.loadMoreError != null);

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
        sliver: SliverToBoxAdapter(
          child: ExpenseReportKpiGrid(items: items),
        ),
      ),
      if (showLoadNotice)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: _PeriodLoadNotice(
              message: success.loadMoreError != null
                  ? 'No se pudieron cargar todos los registros del período.'
                  : 'El período supera el límite de ${ExpensesReportScreen._pageSize * ExpensesReportScreen._maxPages} registros cargados. Acota el rango de fechas para ver el reporte completo.',
              onRetry: success.loadMoreError != null ? _reload : null,
            ),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
        sliver: SliverToBoxAdapter(
          child: ExpenseReportViewToggle(
            selectedIndex: _selectedTab,
            onChanged: (index) => setState(() => _selectedTab = index),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
        sliver: SliverToBoxAdapter(
          child: _selectedTab == 0
              ? ExpenseReportDetailView(items: items, isDesktop: isDesktop)
              : ExpenseReportConsolidatedView(items: items),
        ),
      ),
    ];
  }
}

class _PeriodLoadNotice extends StatelessWidget {
  const _PeriodLoadNotice({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppThemeTokens.warning.withValues(alpha: 0.08),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: AppThemeTokens.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppThemeTokens.warning,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
