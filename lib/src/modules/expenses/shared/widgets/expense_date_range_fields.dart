import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Par de campos de fecha independientes y compactos para filtrar por un rango.
///
/// Inspirado en el estilo de DatePickerListTile y DatePickerButton utilizados
/// en el Buscador de Cotizaciones y reportes de la app, pero optimizado para
/// caber en una toolbar horizontal delgada (36-40px de alto).
class ExpenseDateRangeFields extends StatelessWidget {
  const ExpenseDateRangeFields({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.onClearStart,
    this.onClearEnd,
    this.accentColor = AppThemeTokens.indigo,
    this.startLabel = 'Fecha Inicio',
    this.endLabel = 'Fecha Fin',
    this.breakpoint = 420,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  /// Si es null, el campo no muestra acción para limpiar la fecha.
  final VoidCallback? onClearStart;

  /// Si es null, el campo no muestra acción para limpiar la fecha.
  final VoidCallback? onClearEnd;

  final Color accentColor;
  final String startLabel;
  final String endLabel;

  /// Ancho a partir del cual los campos se muestran en fila.
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final startField = _ExpenseCompactDatePicker(
          label: startLabel,
          value: startDate,
          accentColor: accentColor,
          onTap: () => _pickStartDate(context),
          onClear: onClearStart,
        );
        final endField = _ExpenseCompactDatePicker(
          label: endLabel,
          value: endDate,
          accentColor: accentColor,
          onTap: () => _pickEndDate(context),
          onClear: onClearEnd,
        );

        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              startField,
              const SizedBox(height: 6),
              endField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: startField),
            const SizedBox(width: 8),
            Expanded(child: endField),
          ],
        );
      },
    );
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final today = _today();
    final firstDate = DateTime(today.year - 5);
    final initialDate = _clampDate(
      startDate ?? endDate ?? today,
      firstDate,
      today,
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today,
      helpText: startLabel,
    );
    if (picked == null || !context.mounted) return;
    onStartDateChanged(picked);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final today = _today();
    final fallbackFirst = DateTime(today.year - 5);
    final rawFirst = startDate ?? fallbackFirst;
    final firstDate = rawFirst.isAfter(today) ? today : _dateOnly(rawFirst);
    final initialDate = _clampDate(
      endDate ?? startDate ?? today,
      firstDate,
      today,
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today,
      helpText: endLabel,
    );
    if (picked == null || !context.mounted) return;
    onEndDateChanged(picked);
  }
}

/// Selector de fecha compacto estilo DatePickerListTile/DatePickerButton
class _ExpenseCompactDatePicker extends StatelessWidget {
  const _ExpenseCompactDatePicker({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    String text = 'Todas';
    if (value != null) {
      final today = _today();
      if (value!.year == today.year && value!.month == today.month && value!.day == today.day) {
        text = 'Hoy';
      } else {
        text = DateTimeTool.formatddMMyy(value!);
      }
    }

    final hasValue = value != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppThemeTokens.borderRadiusSm,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: AppThemeTokens.borderRadiusSm,
            border: Border.all(
              color: hasValue ? accentColor.withValues(alpha: 0.4) : AppThemeTokens.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: hasValue ? accentColor : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                        color: hasValue ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasValue && onClear != null)
                IconButton(
                  tooltip: 'Limpiar $label',
                  icon: const Icon(Icons.close_rounded, size: 14),
                  color: const Color(0xFF64748B),
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 22, height: 22),
                  splashRadius: 12,
                )
              else
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _clampDate(DateTime value, DateTime first, DateTime last) {
  final date = _dateOnly(value);
  if (date.isBefore(first)) return first;
  if (date.isAfter(last)) return last;
  return date;
}
