import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_period.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/buttons/secondary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Tarjeta de filtros del reporte: período, rango visible y acciones.
class ExpenseReportFilters extends StatelessWidget {
  const ExpenseReportFilters({
    super.key,
    required this.period,
    required this.range,
    required this.onPeriodSelected,
    required this.onClear,
    required this.onExport,
    required this.isRefreshing,
  });

  final ExpenseReportPeriod period;
  final DateTimeRange range;
  final ValueChanged<ExpenseReportPeriod> onPeriodSelected;
  final VoidCallback onClear;
  final VoidCallback? onExport;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final rangeLabel = '${DateTimeTool.formatddMMyyEs(range.start)} — ${DateTimeTool.formatddMMyyEs(range.end)}';

    final rangeBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de registro',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(color: AppThemeTokens.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: AppThemeTokens.indigo,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  rangeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (isRefreshing) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SecondaryMenuButton(
          onPressed: onClear,
          icon: const Icon(Icons.restart_alt_rounded, size: 17),
          label: const Text(
            'Limpiar',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        ),
        Tooltip(
          message: isRefreshing
              ? 'Espera a que termine la carga del período'
              : onExport == null
              ? 'No hay datos para exportar en este período'
              : 'Exportar reporte',
          child: PrimaryMenuButton(
            onPressed: onExport,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text(
              'Exportar',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    rangeBlock,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: rangeBlock),
                  const SizedBox(width: 16),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final option in ExpenseReportPeriod.values)
                _PeriodPill(
                  label: option.label,
                  isSelected: period == option,
                  onTap: () => onPeriodSelected(option),
                ),
            ],
          ),
        ],
      ),
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
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeTokens.indigo.withValues(alpha: 0.12) : Colors.white,
          borderRadius: AppThemeTokens.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppThemeTokens.indigo.withValues(alpha: 0.45) : const Color(0xFFCBD5E1),
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppThemeTokens.indigo : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
