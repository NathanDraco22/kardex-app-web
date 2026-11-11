import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_date_range_fields.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_kpi_strip.dart';
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

/// Toolbar compacta con totales, filtros y búsqueda de la lista de gastos.
class ExpenseFilterPanel extends StatelessWidget {
  const ExpenseFilterPanel({
    super.key,
    required this.config,
    required this.metrics,
    required this.totalLoaded,
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
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onClearStartDate,
    required this.onClearEndDate,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final ExpenseListConfig config;
  final ExpenseMetrics metrics;
  final int totalLoaded;
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
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final VoidCallback? onClearStartDate;
  final VoidCallback? onClearEndDate;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final statusDropdown = _buildStatusDropdown(context);
              final categoryOrSupplier = config.supportsCategoryFilter
                  ? ExpenseCategoryDropdown(
                      key: ValueKey('filter_category_${selectedCategory ?? 'all'}'),
                      value: selectedCategory,
                      showAllOption: true,
                      label: config.conceptLabel,
                      categories: categories,
                      decoration: _filterDecoration(config.conceptLabel),
                      onChanged: onCategoryChanged,
                    )
                  : (config.supportsSupplierFilter ? _buildSupplierFilter(context) : null);

              final clearButton = TextButton.icon(
                onPressed: hasActiveFilters ? onClearFilters : null,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 15),
                label: const Text(
                  'Limpiar',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  disabledForegroundColor: const Color(0xFFCBD5E1),
                  minimumSize: const Size(36, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppThemeTokens.borderRadiusSm,
                  ),
                ),
              );

              final dateFields = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note_rounded, size: 12, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        'Fecha de registro',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  ExpenseDateRangeFields(
                    startDate: startDate,
                    endDate: endDate,
                    onStartDateChanged: onStartDateChanged,
                    onEndDateChanged: onEndDateChanged,
                    onClearStart: onClearStartDate,
                    onClearEnd: onClearEndDate,
                    accentColor: config.accentColor,
                    breakpoint: 420,
                  ),
                ],
              );

              final searchField = _buildSearchField();

              // Pantallas de escritorio (>= 860px): Filtros en una fila y buscador debajo
              if (constraints.maxWidth >= 860) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(width: 140, child: statusDropdown),
                        if (categoryOrSupplier != null) ...[
                          const SizedBox(width: 8),
                          Expanded(child: categoryOrSupplier),
                        ],
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: dateFields),
                        const SizedBox(width: 6),
                        clearButton,
                      ],
                    ),
                    const SizedBox(height: 6),
                    searchField,
                  ],
                );
              }

              // Vista tablet responsiva compacta (560px - 859px)
              if (constraints.maxWidth >= 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: statusDropdown),
                        if (categoryOrSupplier != null) ...[
                          const SizedBox(width: 8),
                          Expanded(child: categoryOrSupplier),
                        ],
                        const SizedBox(width: 6),
                        clearButton,
                      ],
                    ),
                    const SizedBox(height: 6),
                    dateFields,
                    const SizedBox(height: 6),
                    searchField,
                  ],
                );
              }

              // Pantallas angostas (< 560px)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  statusDropdown,
                  if (categoryOrSupplier != null) ...[
                    const SizedBox(height: 6),
                    categoryOrSupplier,
                  ],
                  const SizedBox(height: 6),
                  dateFields,
                  const SizedBox(height: 6),
                  searchField,
                  const SizedBox(height: 2),
                  Align(alignment: Alignment.centerRight, child: clearButton),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: AppThemeTokens.borderLight),
          const SizedBox(height: 6),
          ExpenseKpiStrip(
            metrics: metrics,
            accentColor: config.accentColor,
            totalLoaded: totalLoaded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return InputDecorator(
      decoration: _filterDecoration('Estado'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ExpenseStatusFilter>(
          key: const Key('expense_status_dropdown'),
          value: selectedStatus,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          items: [
            for (final filter in ExpenseStatusFilter.values)
              DropdownMenuItem<ExpenseStatusFilter>(
                value: filter,
                child: _StatusOption(
                  label: filter.label,
                  color: _statusColor(filter),
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 12.5),
        decoration: InputDecoration(
          hintText: config.searchHint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 17),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.close_rounded, size: 15),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: AppThemeTokens.borderRadiusSm,
            borderSide: const BorderSide(color: AppThemeTokens.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppThemeTokens.borderRadiusSm,
            borderSide: const BorderSide(color: AppThemeTokens.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppThemeTokens.borderRadiusSm,
            borderSide: BorderSide(color: config.accentColor, width: 1.5),
          ),
          isDense: true,
        ),
      ),
    );
  }

  Color _statusColor(ExpenseStatusFilter filter) {
    switch (filter) {
      case ExpenseStatusFilter.all:
        return config.accentColor;
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
      borderRadius: AppThemeTokens.borderRadiusSm,
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
                  fontSize: 12.5,
                  fontWeight: selectedSupplier == null ? FontWeight.w400 : FontWeight.w600,
                  color: selectedSupplier == null ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (selectedSupplier == null)
              const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF94A3B8))
            else
              IconButton(
                tooltip: 'Quitar proveedor',
                onPressed: () => onSupplierChanged(null),
                icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 22, height: 22),
                splashRadius: 12,
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _filterDecoration(String label) {
    final border = OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusSm,
      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      floatingLabelStyle: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: config.accentColor,
      ),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: AppThemeTokens.borderRadiusSm,
        borderSide: BorderSide(color: config.accentColor, width: 1.5),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
