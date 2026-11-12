import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/read_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/write_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/dialogs/create_expense_category_dialog.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_actions.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/widgets/expense_categories_grid.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/widgets/expense_categories_header.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/widgets/expense_category_search_bar.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Catálogo de categorías de gastos.
///
/// Orquesta búsqueda, estados de carga y el grid responsive; las tarjetas y el
/// estado vacío viven en `widgets/`.
class ExpenseCategoriesScreen extends StatelessWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseCategoriesRepository = context.read<ExpenseCategoriesRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = ReadExpenseCategoryCubit(expenseCategoriesRepository);
            unawaited(cubit.getAll());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => WriteExpenseCategoryCubit(expenseCategoriesRepository),
        ),
      ],
      child: const _ExpenseCategoriesScaffold(),
    );
  }
}

class _ExpenseCategoriesScaffold extends StatefulWidget {
  const _ExpenseCategoriesScaffold();

  @override
  State<_ExpenseCategoriesScaffold> createState() => _ExpenseCategoriesScaffoldState();
}

class _ExpenseCategoriesScaffoldState extends State<_ExpenseCategoriesScaffold> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog() async {
    final created = await showCreateExpenseCategoryDialog(context);
    if (!mounted || created == null) return;

    context.read<ReadExpenseCategoryCubit>().markExpenseCategoryCreated(created);
    _showSnackBar('Categoría "${created.name}" creada correctamente.');
  }

  Future<void> _openEditDialog(ExpenseCategoryInDb category) async {
    final updated = await showCreateExpenseCategoryDialog(
      context,
      category: category,
    );
    if (!mounted || updated == null) return;

    context.read<ReadExpenseCategoryCubit>().markExpenseCategoryUpdated(updated);
    _showSnackBar('Categoría "${updated.name}" actualizada correctamente.');
  }

  Future<void> _refresh() {
    return context.read<ReadExpenseCategoryCubit>().refresh();
  }

  Future<void> _retry() {
    return context.read<ReadExpenseCategoryCubit>().getAll();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _showSnackBar(String message) {
    ExpenseActions.showSnackBar(context, message);
  }

  List<ExpenseCategoryInDb> _filterCategories(List<ExpenseCategoryInDb> categories) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return categories;

    return categories
        .where(
          (category) =>
              category.name.toLowerCase().contains(query) || (category.description ?? '').toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Gastos'),
      ),
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: _openCreateDialog,
          backgroundColor: AppThemeTokens.indigo,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nueva Categoría'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ReadExpenseCategoryCubit, ReadExpenseCategoryState>(
          builder: (context, state) {
            final successState = state is ReadExpenseCategorySuccess ? state : null;
            final allCategories = successState == null
                ? const <ExpenseCategoryInDb>[]
                : successState.items.where((category) => !category.isDeleted).toList(growable: false);
            final filteredCategories = _filterCategories(allCategories);
            final isRefreshing = state is ReadExpenseCategorySearching;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                final horizontalPadding = isDesktop ? (constraints.maxWidth >= 1280 ? 32.0 : 16.0) : 4.0;
                final topPadding = isDesktop ? 20.0 : 8.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: RefreshIndicator(
                      color: AppThemeTokens.indigo,
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topPadding,
                          horizontalPadding,
                          32,
                        ),
                        children: [
                          ExpenseCategoriesHeader(
                            categoryCount: allCategories.length,
                            isRefreshing: isRefreshing,
                            onRefresh: _refresh,
                            onCreate: _openCreateDialog,
                          ),
                          const SizedBox(height: 16),
                          ExpenseCategorySearchBar(
                            controller: _searchController,
                            query: _searchQuery,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            onClear: _clearSearch,
                          ),
                          if (isRefreshing) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              minHeight: 2,
                              color: AppThemeTokens.indigo,
                              backgroundColor: AppThemeTokens.indigo.withValues(alpha: 0.12),
                            ),
                          ],
                          if (successState?.refreshError != null) ...[
                            const SizedBox(height: 10),
                            _CategoryRefreshNotice(onRetry: _refresh),
                          ],
                          const SizedBox(height: 12),
                          ..._buildContent(
                            state: state,
                            allCategories: allCategories,
                            filteredCategories: filteredCategories,
                          ),
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
    required ReadExpenseCategoryState state,
    required List<ExpenseCategoryInDb> allCategories,
    required List<ExpenseCategoryInDb> filteredCategories,
  }) {
    if (state is ReadExpenseCategoryInitial || state is ReadExpenseCategoryLoading) {
      return [
        AppSkeletonLoader.cards(count: 4, padding: EdgeInsets.zero),
      ];
    }

    if (state is ReadExpenseCategoryError) {
      return [
        AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'No se pudieron cargar las categorías',
          subtitle: state.message,
          accentColor: AppThemeTokens.danger,
          actionLabel: 'Reintentar',
          actionIcon: Icons.refresh_rounded,
          onAction: _retry,
        ),
      ];
    }

    if (allCategories.isEmpty) {
      return [
        ExpenseCategoriesEmptyState(
          hasSearch: false,
          query: '',
          onCreate: _openCreateDialog,
          onClearSearch: _clearSearch,
        ),
      ];
    }

    if (filteredCategories.isEmpty) {
      return [
        ExpenseCategoriesEmptyState(
          hasSearch: true,
          query: _searchQuery.trim(),
          onCreate: _openCreateDialog,
          onClearSearch: _clearSearch,
        ),
      ];
    }

    final successState = state as ReadExpenseCategorySuccess;
    return [
      ExpenseCategoriesGrid(
        categories: filteredCategories,
        newIds: successState.newItems.map((category) => category.id).toSet(),
        updatedIds: successState.updatedItems.map((category) => category.id).toSet(),
        onEdit: _openEditDialog,
      ),
    ];
  }
}

class _CategoryRefreshNotice extends StatelessWidget {
  const _CategoryRefreshNotice({required this.onRetry});

  final VoidCallback onRetry;

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
            Icons.cloud_off_rounded,
            size: 17,
            color: AppThemeTokens.warning,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No se pudieron actualizar las categorías. Se muestran los datos anteriores.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
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
