import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_period.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_date_range_fields.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_filter_card.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/buttons/secondary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Barra de filtros compacta del reporte: fechas estilo cotizaciones, atajos inline y acciones.
class ExpenseReportFilters extends StatelessWidget {
  const ExpenseReportFilters({
    super.key,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.onPeriodSelected,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onClear,
    required this.onExport,
    required this.isRefreshing,
  });

  final ExpenseReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<ExpenseReportPeriod> onPeriodSelected;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final VoidCallback onClear;
  final VoidCallback? onExport;
  final bool isRefreshing;

  /// A partir de este ancho los filtros se muestran siempre visibles.
  static const double _collapsibleBreakpoint = 860;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dateFields = _buildDateFields();
        final clearButton = _buildClearButton();
        final exportButton = _buildExportButton();
        final shortcuts = _buildShortcuts();

        if (constraints.maxWidth < _collapsibleBreakpoint) {
          return ExpenseFilterCard(
            headerTrailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRefreshing) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                exportButton,
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                dateFields,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: clearButton),
                const SizedBox(height: 8),
                shortcuts,
              ],
            ),
          );
        }

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            clearButton,
            const SizedBox(width: 8),
            exportButton,
            if (isRefreshing) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  if (constraints.maxWidth >= 720) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: dateFields),
                        const SizedBox(width: 12),
                        actions,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dateFields,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: actions),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              shortcuts,
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateFields() {
    return ExpenseDateRangeFields(
      startDate: startDate,
      endDate: endDate,
      onStartDateChanged: onStartDateChanged,
      onEndDateChanged: onEndDateChanged,
      breakpoint: 280,
    );
  }

  Widget _buildClearButton() {
    return SecondaryMenuButton(
      onPressed: onClear,
      icon: const Icon(Icons.restart_alt_rounded, size: 15),
      label: const Text(
        'Limpiar',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  Widget _buildExportButton() {
    return Tooltip(
      message: isRefreshing
          ? 'Espera a que termine la carga del período'
          : onExport == null
          ? 'No hay datos para exportar en este período'
          : 'Exportar reporte',
      child: PrimaryMenuButton(
        onPressed: onExport,
        icon: const Icon(Icons.download_rounded, size: 16),
        label: const Text(
          'Exportar',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildShortcuts() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Atajos:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in ExpenseReportPeriod.values)
                  if (option != ExpenseReportPeriod.custom) ...[
                    _PeriodPill(
                      label: option.label,
                      isSelected: period == option,
                      onTap: () => onPeriodSelected(option),
                    ),
                    const SizedBox(width: 6),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeTokens.borderRadiusFull,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 28,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeTokens.indigo.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: AppThemeTokens.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppThemeTokens.indigo.withValues(alpha: 0.45) : AppThemeTokens.borderLight,
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppThemeTokens.indigo : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
