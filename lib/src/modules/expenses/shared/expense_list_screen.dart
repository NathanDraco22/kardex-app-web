import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_actions.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_filter_panel.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_kpi_strip.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_list_tile.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_page_header.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_table_header.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Orquestador responsive compartido por las listas de gastos.
///
/// Decide el layout por ancho disponible: tabla en desktop y tarjetas en
/// móvil/tablet. No conoce detalles de creación/edición; esos llegan por
/// [ExpenseListConfig].
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({
    super.key,
    required this.config,
  });

  final ExpenseListConfig config;

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  static const double _desktopBreakpoint = 900;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  ExpenseStatusFilter _statusFilter = ExpenseStatusFilter.all;
  String? _selectedCategory;
  SupplierInDb? _selectedSupplier;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeTokens.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Gastos',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppThemeTokens.borderLight),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
          builder: (context, state) {
            final successState = state is ReadExpenseSuccess ? state : null;
            final visibleItems = successState == null ? const <ExpenseInDb>[] : _visibleItems(successState);
            final metrics = ExpenseMetrics.fromExpenses(visibleItems);

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 1280 ? 32.0 : 16.0;
                final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: RefreshIndicator(
                      color: widget.config.accentColor,
                      onRefresh: () => context.read<ReadExpenseCubit>().refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                            sliver: SliverToBoxAdapter(
                              child: ExpensePageHeader(
                                config: widget.config,
                                isRefreshing: state is ReadExpenseSearching,
                                onRefresh: () => context.read<ReadExpenseCubit>().refresh(),
                                onCreate: _createExpense,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
                            sliver: SliverToBoxAdapter(
                              child: ExpenseKpiStrip(
                                metrics: metrics,
                                accentColor: widget.config.accentColor,
                                totalLoaded: successState?.totalLoaded ?? 0,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
                            sliver: SliverToBoxAdapter(
                              child: ExpenseFilterPanel(
                                config: widget.config,
                                searchController: _searchController,
                                searchQuery: _searchQuery,
                                onSearchChanged: _onSearchChanged,
                                selectedStatus: _statusFilter,
                                onStatusChanged: _onStatusChanged,
                                selectedCategory: _selectedCategory,
                                onCategoryChanged: _onCategoryChanged,
                                categories: context.read<ReadExpenseCubit>().expenseCategories,
                                selectedSupplier: _selectedSupplier,
                                onSupplierChanged: _onSupplierChanged,
                                dateRange: _dateRange,
                                onDateRangeChanged: _onDateRangeChanged,
                                hasActiveFilters: _hasActiveFilters,
                                onClearFilters: _clearFilters,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
                            sliver: SliverToBoxAdapter(
                              child: SizedBox(
                                height: 2,
                                child: state is ReadExpenseSearching
                                    ? LinearProgressIndicator(
                                        minHeight: 2,
                                        color: widget.config.accentColor,
                                        backgroundColor: widget.config.accentColor.withValues(alpha: 0.12),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          ..._buildContent(
                            context: context,
                            state: state,
                            successState: successState,
                            visibleItems: visibleItems,
                            isDesktop: isDesktop,
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
    required List<ExpenseInDb> visibleItems,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    if (state is ReadExpenseInitial || state is ReadExpenseLoading) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: isDesktop
                ? AppSkeletonLoader.listTile(count: 6, padding: EdgeInsets.zero)
                : AppSkeletonLoader.cards(count: 4, padding: EdgeInsets.zero),
          ),
        ),
      ];
    }

    if (state is ReadExpenseError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'No se pudieron cargar los gastos',
            subtitle: state.message,
            accentColor: AppThemeTokens.danger,
            actionLabel: 'Reintentar',
            actionIcon: Icons.refresh_rounded,
            onAction: () => context.read<ReadExpenseCubit>().refresh(),
          ),
        ),
      ];
    }

    if (visibleItems.isEmpty) {
      final hasActiveFilters = _hasActiveFilters;
      final hasMore = successState?.hasMore ?? false;
      final isLoadingMore = successState?.isLoadingMore ?? false;
      final loadMoreError = successState?.loadMoreError;
      final showLoadMore = successState != null && (hasMore || isLoadingMore || loadMoreError != null);

      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppEmptyState(
                icon: hasActiveFilters ? Icons.search_off_rounded : widget.config.icon,
                title: hasActiveFilters ? 'Sin resultados' : widget.config.emptyTitle,
                subtitle: hasActiveFilters
                    ? 'No hay gastos que coincidan con los filtros seleccionados.'
                    : widget.config.emptySubtitle,
                accentColor: widget.config.accentColor,
                actionLabel: hasActiveFilters ? 'Limpiar filtros' : widget.config.createButtonLabel,
                actionIcon: hasActiveFilters ? Icons.filter_alt_off_rounded : Icons.add_rounded,
                onAction: hasActiveFilters ? _clearFilters : _createExpense,
              ),
              if (showLoadMore)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  child: _buildLoadMoreSection(
                    isLoadingMore: isLoadingMore,
                    error: loadMoreError,
                  ),
                ),
            ],
          ),
        ),
      ];
    }

    final success = successState!;
    final newIds = success.newItems.map((expense) => expense.id).toSet();
    final updatedIds = success.updatedItems.map((expense) => expense.id).toSet();

    final slivers = <Widget>[];

    if (isDesktop) {
      // Fase 4: convertir estas filas a SliverList conservando el contenedor
      // redondeado; por ahora el volumen esperado permite construirlas en bloque.
      final rows = <Widget>[];
      for (var index = 0; index < visibleItems.length; index++) {
        final expense = visibleItems[index];
        rows.add(
          ExpenseTableRow(
            key: ValueKey(expense.id),
            expense: expense,
            config: widget.config,
            isNew: newIds.contains(expense.id),
            isUpdated: updatedIds.contains(expense.id),
            showDivider: index < visibleItems.length - 1,
            onTap: () => widget.config.onOpenViewer(context, expense),
          ),
        );
      }

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppThemeTokens.borderRadiusLg,
                border: Border.all(color: AppThemeTokens.borderLight),
                boxShadow: AppThemeTokens.subtleCardShadow(),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ExpenseTableHeader(conceptLabel: widget.config.conceptLabel),
                  ...rows,
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          sliver: SliverList.separated(
            itemCount: visibleItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final expense = visibleItems[index];
              return ExpenseCardTile(
                key: ValueKey(expense.id),
                expense: expense,
                config: widget.config,
                isNew: newIds.contains(expense.id),
                isUpdated: updatedIds.contains(expense.id),
                onTap: () => widget.config.onOpenViewer(context, expense),
              );
            },
          ),
        ),
      );
    }

    if (success.hasMore || success.isLoadingMore || success.loadMoreError != null) {
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: _buildLoadMoreSection(
                isLoadingMore: success.isLoadingMore,
                error: success.loadMoreError,
              ),
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  List<ExpenseInDb> _visibleItems(ReadExpenseSuccess state) {
    final deletedIds = state.deletedItems.map((expense) => expense.id).toSet();
    final query = _searchQuery.trim().toLowerCase();

    return state.items
        .where((expense) {
          if (expense.isDeleted || deletedIds.contains(expense.id)) return false;

          switch (_statusFilter) {
            case ExpenseStatusFilter.pending:
              if (expense.status != ExpenseStatus.open &&
                  expense.status != ExpenseStatus.draft &&
                  expense.status != ExpenseStatus.partiallyPaid) {
                return false;
              }
            case ExpenseStatusFilter.paid:
              if (expense.status != ExpenseStatus.paid) return false;
            case ExpenseStatusFilter.overdue:
              if (!isExpenseOverdue(expense)) return false;
            case ExpenseStatusFilter.all:
              break;
          }

          if (_selectedCategory != null && expense.category != _selectedCategory) return false;
          if (_selectedSupplier != null && expense.supplierId != _selectedSupplier!.id) return false;

          final range = _dateRange;
          if (range != null) {
            if (expense.createdAt.isBefore(range.start.startOfDay()) ||
                expense.createdAt.isAfter(range.end.endOfDay())) {
              return false;
            }
          }

          if (query.isNotEmpty) {
            final searchable = [
              expense.category,
              expense.supplierName,
              expense.docNumber,
              expense.description ?? '',
            ].join(' ').toLowerCase();

            if (!searchable.contains(query)) return false;
          }

          return true;
        })
        .toList(growable: false);
  }

  bool get _hasActiveFilters {
    return _statusFilter != ExpenseStatusFilter.all ||
        _selectedCategory != null ||
        _selectedSupplier != null ||
        _dateRange != null ||
        _searchQuery.trim().isNotEmpty;
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _onStatusChanged(ExpenseStatusFilter value) {
    setState(() => _statusFilter = value);
    _applyFilters();
  }

  void _onCategoryChanged(String? value) {
    setState(() => _selectedCategory = value);
    _applyFilters();
  }

  void _onSupplierChanged(SupplierInDb? value) {
    setState(() => _selectedSupplier = value);
    _applyFilters();
  }

  void _onDateRangeChanged(DateTimeRange? value) {
    setState(() => _dateRange = value);
    _applyFilters();
  }

  void _applyFilters() {
    final range = _dateRange;

    context.read<ReadExpenseCubit>().applyFilters(
      status: _statusFilter.apiStatus,
      category: widget.config.supportsCategoryFilter ? _selectedCategory : null,
      supplierId: widget.config.supportsSupplierFilter ? _selectedSupplier?.id : null,
      startDate: range?.start.startOfDay().millisecondsSinceEpoch,
      endDate: range?.end.endOfDay().millisecondsSinceEpoch,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _statusFilter = ExpenseStatusFilter.all;
      _selectedCategory = null;
      _selectedSupplier = null;
      _dateRange = null;
    });
    context.read<ReadExpenseCubit>().clearFilters();
  }

  Widget _buildLoadMoreSection({
    required bool isLoadingMore,
    String? error,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (error != null) ...[
          Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemeTokens.danger.withValues(alpha: 0.08),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: AppThemeTokens.danger,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: isLoadingMore ? null : () => context.read<ReadExpenseCubit>().loadMore(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppThemeTokens.danger,
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        _buildLoadMoreButton(isLoadingMore: isLoadingMore),
      ],
    );
  }

  Widget _buildLoadMoreButton({required bool isLoadingMore}) {
    return OutlinedButton.icon(
      onPressed: isLoadingMore ? null : () => context.read<ReadExpenseCubit>().loadMore(),
      icon: isLoadingMore
          ? SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.config.accentColor,
              ),
            )
          : const Icon(Icons.expand_more_rounded, size: 18),
      label: Text(
        isLoadingMore ? 'Cargando más...' : 'Cargar más registros',
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.config.accentColor,
        side: BorderSide(color: widget.config.accentColor.withValues(alpha: 0.35)),
        minimumSize: const Size(44, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
      ),
    );
  }

  Future<void> _createExpense() async {
    final created = await widget.config.onCreate(context);
    if (!mounted || !context.mounted || created == null) return;

    ExpenseActions.showSnackBar(context, 'Gasto creado correctamente');
  }
}
