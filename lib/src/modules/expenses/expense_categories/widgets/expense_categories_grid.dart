import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/widgets/expense_category_card.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Grid responsive del catálogo de categorías de gastos.
class ExpenseCategoriesGrid extends StatelessWidget {
  const ExpenseCategoriesGrid({
    super.key,
    required this.categories,
    required this.onEdit,
    this.newIds = const <String>{},
    this.updatedIds = const <String>{},
  });

  final List<ExpenseCategoryInDb> categories;
  final ValueChanged<ExpenseCategoryInDb> onEdit;
  final Set<String> newIds;
  final Set<String> updatedIds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 700
            ? 1
            : constraints.maxWidth < 1100
            ? 2
            : 3;

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 200,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return ExpenseCategoryCard(
              key: ValueKey('expense-category-${category.id}'),
              category: category,
              isNew: newIds.contains(category.id),
              isUpdated: updatedIds.contains(category.id),
              onEdit: () => onEdit(category),
            );
          },
        );
      },
    );
  }
}

/// Estado vacío del catálogo, con variante para búsquedas sin resultados.
class ExpenseCategoriesEmptyState extends StatelessWidget {
  const ExpenseCategoriesEmptyState({
    super.key,
    required this.hasSearch,
    required this.query,
    required this.onCreate,
    required this.onClearSearch,
  });

  final bool hasSearch;
  final String query;
  final VoidCallback onCreate;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    if (hasSearch) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: query.isEmpty ? 'Sin resultados' : 'Sin resultados para "$query"',
        subtitle: 'Verifica el término o limpia la búsqueda para ver todas las categorías.',
        accentColor: AppThemeTokens.indigo,
        actionLabel: 'Limpiar búsqueda',
        actionIcon: Icons.close_rounded,
        onAction: onClearSearch,
      );
    }

    return AppEmptyState(
      icon: Icons.category_outlined,
      title: 'Sin categorías de gastos',
      subtitle: 'Crea tu primera categoría para clasificar los gastos operativos del negocio.',
      accentColor: AppThemeTokens.indigo,
      actionLabel: 'Nueva Categoría',
      actionIcon: Icons.add_rounded,
      onAction: onCreate,
    );
  }
}
