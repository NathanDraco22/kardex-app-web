import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_actions.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_filter_panel.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_list_tile.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_table_header.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
      builder: (context, state) {
        final successState = state is ReadExpenseSuccess ? state : null;
        final visibleItems = successState == null ? const <ExpenseInDb>[] : _visibleItems(successState);
        final metrics = ExpenseMetrics.fromExpenses(visibleItems);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= _desktopBreakpoint;
            final horizontalPadding = isDesktop ? (constraints.maxWidth >= 1280 ? 32.0 : 16.0) : 4.0;
            final topFilterPadding = isDesktop ? 12.0 : 4.0;

            return Scaffold(
              appBar: AppBar(
                title: Tooltip(
                  message: widget.config.subtitle,
                  child: Text(
                    widget.config.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                actions: [
                  BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
                    builder: (context, state) {
                      final isRefreshing = state is ReadExpenseSearching;
                      return IconButton(
                        tooltip: 'Actualizar',
                        onPressed: isRefreshing ? null : () => context.read<ReadExpenseCubit>().refresh(),
                        icon: isRefreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 21),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              floatingActionButton: Visibility(
                visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
                child: FloatingActionButton.extended(
                  onPressed: _createExpense,
                  backgroundColor: widget.config.accentColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(widget.config.createButtonLabel),
                ),
              ),
              bottomNavigationBar: isDesktop
                  ? null
                  : _ExpenseListBottomAppBar(
                      metrics: metrics,
                      accentColor: widget.config.accentColor,
                    ),
              body: SafeArea(
                top: false,
                child: Align(
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
                            padding: EdgeInsets.fromLTRB(horizontalPadding, topFilterPadding, horizontalPadding, 0),
                            sliver: SliverToBoxAdapter(
                              child: ExpenseFilterPanel(
                                config: widget.config,
                                metrics: metrics,
                                totalLoaded: successState?.totalLoaded ?? 0,
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
                                startDate: _startDate,
                                endDate: _endDate,
                                onStartDateChanged: _onStartDateChanged,
                                onEndDateChanged: _onEndDateChanged,
                                onClearStartDate: _onClearStartDate,
                                onClearEndDate: _onClearEndDate,
                                hasActiveFilters: _hasActiveFilters,
                                onClearFilters: _clearFilters,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(horizontalPadding, isDesktop ? 10 : 4, horizontalPadding, 0),
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
                ),
              ),
            );
          },
        );
      },
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
        _buildExpandedSliver(
          horizontalPadding: horizontalPadding,
          children: [
            AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar los gastos',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => context.read<ReadExpenseCubit>().refresh(),
            ),
          ],
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
        _buildExpandedSliver(
          horizontalPadding: horizontalPadding,
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
          padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 0),
          sliver: SliverToBoxAdapter(
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0; index < visibleItems.length; index++) ...[
                    ExpenseCardTile(
                      key: ValueKey(visibleItems[index].id),
                      expense: visibleItems[index],
                      config: widget.config,
                      isNew: newIds.contains(visibleItems[index].id),
                      isUpdated: updatedIds.contains(visibleItems[index].id),
                      inContinuousCard: true,
                      index: index,
                      onTap: () => widget.config.onOpenViewer(context, visibleItems[index]),
                    ),
                    if (index < visibleItems.length - 1)
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                  ],
                ],
              ),
            ),
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

  /// Sliver de altura natural para estados vacíos/error.
  ///
  /// `SliverFillRemaining(hasScrollBody: false)` impone una altura fija que
  /// desborda en ventanas bajas cuando el estado vacío incluye acciones
  /// adicionales. Este sliver ocupa el espacio restante cuando sobra, pero
  /// permite que el contenido crezca y lo desplaza el scroll principal.
  Widget _buildExpandedSliver({
    required double horizontalPadding,
    required List<Widget> children,
  }) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        return SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.remainingPaintExtent,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        );
      },
    );
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

          final startDate = _startDate;
          if (startDate != null && expense.createdAt.isBefore(startDate.startOfDay())) {
            return false;
          }
          final endDate = _endDate;
          if (endDate != null && expense.createdAt.isAfter(endDate.endOfDay())) {
            return false;
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
        _startDate != null ||
        _endDate != null ||
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

  void _onStartDateChanged(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    setState(() {
      _startDate = normalized;
      final end = _endDate;
      if (end != null && end.isBefore(normalized)) {
        _endDate = normalized;
      }
    });
    _applyFilters();
  }

  void _onEndDateChanged(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    setState(() {
      _endDate = normalized;
      final start = _startDate;
      if (start != null && start.isAfter(normalized)) {
        _startDate = normalized;
      }
    });
    _applyFilters();
  }

  void _onClearStartDate() {
    setState(() => _startDate = null);
    _applyFilters();
  }

  void _onClearEndDate() {
    setState(() => _endDate = null);
    _applyFilters();
  }

  void _applyFilters() {
    context.read<ReadExpenseCubit>().applyFilters(
      status: _statusFilter.apiStatus,
      category: widget.config.supportsCategoryFilter ? _selectedCategory : null,
      supplierId: widget.config.supportsSupplierFilter ? _selectedSupplier?.id : null,
      startDate: _startDate?.startOfDay().millisecondsSinceEpoch,
      endDate: _endDate?.endOfDay().millisecondsSinceEpoch,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _statusFilter = ExpenseStatusFilter.all;
      _selectedCategory = null;
      _selectedSupplier = null;
      _startDate = null;
      _endDate = null;
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

class _ExpenseListBottomAppBar extends StatelessWidget {
  const _ExpenseListBottomAppBar({
    required this.metrics,
    required this.accentColor,
  });

  final ExpenseMetrics metrics;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (metrics.count == 0) return const SizedBox.shrink();

    final pendingTotal = metrics.pending;

    return BottomAppBar(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: 'Total',
                bigTitle: NumberFormatter.convertToMoneyLike(metrics.total),
                bigTitleColor: accentColor,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: 'Pagado',
                bigTitle: NumberFormatter.convertToMoneyLike(metrics.paid),
                bigTitleColor: Colors.green.shade700,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: 'Pendiente',
                bigTitle: NumberFormatter.convertToMoneyLike(pendingTotal),
                bigTitleColor: pendingTotal > 0 ? Colors.red.shade700 : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
