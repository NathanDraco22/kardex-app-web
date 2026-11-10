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

/// Tarjeta compacta con totales, filtros y búsqueda de la lista de gastos.
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpenseKpiStrip(
            metrics: metrics,
            accentColor: config.accentColor,
            totalLoaded: totalLoaded,
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppThemeTokens.borderLight),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final controls = <Widget>[
                _buildStatusDropdown(context),
                if (config.supportsCategoryFilter)
                  ExpenseCategoryDropdown(
                    key: ValueKey('filter_category_${selectedCategory ?? 'all'}'),
                    value: selectedCategory,
                    showAllOption: true,
                    label: config.conceptLabel,
                    categories: categories,
                    decoration: _filterDecoration(config.conceptLabel),
                    onChanged: onCategoryChanged,
                  ),
                if (config.supportsSupplierFilter) _buildSupplierFilter(context),
              ];

              final clearButton = TextButton.icon(
                onPressed: hasActiveFilters ? onClearFilters : null,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text(
                  'Limpiar',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  disabledForegroundColor: const Color(0xFFCBD5E1),
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppThemeTokens.borderRadiusSm,
                  ),
                ),
              );

              final dates = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Fecha de registro',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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

              final search = _buildSearchField();

              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < controls.length; index++) ...[
                      if (index > 0) const SizedBox(height: 8),
                      controls[index],
                    ],
                    const SizedBox(height: 2),
                    Align(alignment: Alignment.centerRight, child: clearButton),
                    const SizedBox(height: 8),
                    dates,
                    const SizedBox(height: 10),
                    search,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      for (var index = 0; index < controls.length; index++) ...[
                        if (index > 0) const SizedBox(width: 10),
                        Expanded(child: controls[index]),
                      ],
                      const SizedBox(width: 6),
                      clearButton,
                    ],
                  ),
                  const SizedBox(height: 10),
                  dates,
                  const SizedBox(height: 10),
                  search,
                ],
              );
            },
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
            Icons.expand_more_rounded,
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
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: config.searchHint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.search_rounded, size: 19),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  fontSize: 13,
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
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                splashRadius: 18,
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _filterDecoration(String label) {
    final border = OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
      floatingLabelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: config.accentColor,
      ),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: AppThemeTokens.borderRadiusMd,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
