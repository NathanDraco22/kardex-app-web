import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/expense_report_period.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/buttons/secondary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Tarjeta de filtros del reporte: fechas separadas, atajos y acciones.
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

  @override
  Widget build(BuildContext context) {
    final dateFields = LayoutBuilder(
      builder: (context, constraints) {
        final startField = _ReportDateField(
          label: 'Fecha Inicio',
          value: startDate,
          onTap: () => _pickStartDate(context),
        );
        final endField = _ReportDateField(
          label: 'Fecha Fin',
          value: endDate,
          onTap: () => _pickEndDate(context),
        );

        if (constraints.maxWidth < 460) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              startField,
              const SizedBox(height: 10),
              endField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: startField),
            const SizedBox(width: 10),
            Expanded(child: endField),
          ],
        );
      },
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
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppThemeTokens.indigo.withValues(alpha: 0.10),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(
                    color: AppThemeTokens.indigo.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppThemeTokens.indigo,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Período del reporte',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (isRefreshing)
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(flex: 3, child: dateFields),
                    const SizedBox(width: 16),
                    actions,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  dateFields,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: actions),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'ATAJOS RÁPIDOS',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final option in ExpenseReportPeriod.values)
                if (option != ExpenseReportPeriod.custom)
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

  Future<void> _pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Fecha Inicio',
    );
    if (picked == null || !context.mounted) return;
    onStartDateChanged(picked);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Fecha Fin',
    );
    if (picked == null || !context.mounted) return;
    onEndDateChanged(picked);
  }
}

class _ReportDateField extends StatelessWidget {
  const _ReportDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeTokens.borderRadiusMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          floatingLabelStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppThemeTokens.indigo,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: AppThemeTokens.borderRadiusMd,
            borderSide: const BorderSide(
              color: AppThemeTokens.indigo,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppThemeTokens.indigo,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                DateTimeTool.formatddMMyyEs(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
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
