import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/supplier_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dropdown/expense_category_dropdown.dart';
import 'package:kardex_business/kardex_business.dart';

/// Filtros rápidos disponibles en la lista de gastos.
enum ExpenseStatusFilter {
  all('Todos'),
  pending('Pendientes'),
  paid('Pagados'),
  overdue('Vencidos');

  const ExpenseStatusFilter(this.label);

  final String label;

  /// Valor de estado aceptado por [ExpenseQueryParams.status].
  ///
  /// El backend solo acepta un estado por petición. "Pendientes" agrupa
  /// borradores, abiertos y pagos parciales, por lo que se resuelve con el
  /// filtro local de la lista en lugar de enviar `status` al servidor.
  String? get apiStatus {
    switch (this) {
      case ExpenseStatusFilter.all:
      case ExpenseStatusFilter.pending:
      case ExpenseStatusFilter.overdue:
        return null;
      case ExpenseStatusFilter.paid:
        return ExpenseStatus.paid.name;
    }
  }
}

/// Panel de búsqueda y filtros de la lista de gastos.
class ExpenseFilterPanel extends StatelessWidget {
  const ExpenseFilterPanel({
    super.key,
    required this.config,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
    required this.selectedSupplier,
    required this.onSupplierChanged,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final ExpenseListConfig config;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ExpenseStatusFilter selectedStatus;
  final ValueChanged<ExpenseStatusFilter> onStatusChanged;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final List<ExpenseCategoryInDb> categories;
  final SupplierInDb? selectedSupplier;
  final ValueChanged<SupplierInDb?> onSupplierChanged;
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: config.searchHint,
              hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: AppThemeTokens.borderRadiusMd,
                borderSide: const BorderSide(color: AppThemeTokens.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppThemeTokens.borderRadiusMd,
                borderSide: const BorderSide(color: AppThemeTokens.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppThemeTokens.borderRadiusMd,
                borderSide: BorderSide(color: config.accentColor, width: 1.5),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final filter in ExpenseStatusFilter.values)
                _FilterPill(
                  label: filter.label,
                  isSelected: selectedStatus == filter,
                  color: _pillColor(filter, config.accentColor),
                  onTap: () => onStatusChanged(filter),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final controls = <Widget>[
                if (config.supportsCategoryFilter)
                  ExpenseCategoryDropdown(
                    key: ValueKey('filter_category_${selectedCategory ?? 'all'}'),
                    value: selectedCategory,
                    showAllOption: true,
                    label: config.conceptLabel,
                    categories: categories,
                    onChanged: onCategoryChanged,
                  ),
                if (config.supportsSupplierFilter) _buildSupplierFilter(context),
                _buildDateRangeFilter(context),
              ];

              final clearButton = TextButton.icon(
                onPressed: hasActiveFilters ? onClearFilters : null,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text(
                  'Limpiar filtros',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  disabledForegroundColor: const Color(0xFFCBD5E1),
                  minimumSize: const Size(44, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusSm),
                ),
              );

              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < controls.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      controls[i],
                    ],
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: clearButton),
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < controls.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: controls[i]),
                  ],
                  const SizedBox(width: 10),
                  clearButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _pillColor(ExpenseStatusFilter filter, Color accentColor) {
    switch (filter) {
      case ExpenseStatusFilter.all:
        return accentColor;
      case ExpenseStatusFilter.pending:
        return AppThemeTokens.warning;
      case ExpenseStatusFilter.paid:
        return AppThemeTokens.success;
      case ExpenseStatusFilter.overdue:
        return AppThemeTokens.danger;
    }
  }

  Widget _buildSupplierFilter(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showSupplierSelectionDialog(context);
        if (selected == null || !context.mounted) return;
        onSupplierChanged(selected);
      },
      borderRadius: AppThemeTokens.borderRadiusMd,
      child: InputDecorator(
        decoration: _filterDecoration('Proveedor'),
        isEmpty: selectedSupplier == null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedSupplier?.name ?? 'Todos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selectedSupplier == null ? FontWeight.w400 : FontWeight.w600,
                  color: selectedSupplier == null ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (selectedSupplier == null)
              const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF94A3B8))
            else
              IconButton(
                tooltip: 'Quitar proveedor',
                onPressed: () => onSupplierChanged(null),
                icon: const Icon(Icons.close_rounded, size: 15, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: now,
          initialDateRange: dateRange,
          helpText: 'Fecha de registro',
          saveText: 'Aplicar',
        );
        if (picked == null || !context.mounted) return;
        onDateRangeChanged(picked);
      },
      borderRadius: AppThemeTokens.borderRadiusMd,
      child: InputDecorator(
        decoration: _filterDecoration('Fecha de registro'),
        isEmpty: dateRange == null,
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _dateRangeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: dateRange == null ? FontWeight.w400 : FontWeight.w600,
                  color: dateRange == null ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (dateRange == null)
              const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF94A3B8))
            else
              IconButton(
                tooltip: 'Quitar fecha de registro',
                onPressed: () => onDateRangeChanged(null),
                icon: const Icon(Icons.close_rounded, size: 15, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }

  String get _dateRangeLabel {
    final range = dateRange;
    if (range == null) return 'Todas las fechas';
    return '${DateTimeTool.formatddMMyyEs(range.start)} - ${DateTimeTool.formatddMMyyEs(range.end)}';
  }

  InputDecoration _filterDecoration(String label) {
    final border = OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
    );

    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: AppThemeTokens.borderRadiusMd,
        borderSide: BorderSide(color: config.accentColor, width: 1.5),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeTokens.borderRadiusFull,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: AppThemeTokens.borderRadiusFull,
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.45) : const Color(0xFFCBD5E1),
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
