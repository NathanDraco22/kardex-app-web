import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Par de campos de fecha independientes para filtrar por un rango.
///
/// Se usa tanto en el reporte de gastos como en el panel de filtros de las
/// listas para que ambos compartan la misma apariencia y el mismo
/// comportamiento de los calendarios.
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
    this.breakpoint = 460,
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
        final startField = _ExpenseDateRangeField(
          label: startLabel,
          value: startDate,
          accentColor: accentColor,
          onTap: () => _pickStartDate(context),
          onClear: onClearStart,
        );
        final endField = _ExpenseDateRangeField(
          label: endLabel,
          value: endDate,
          accentColor: accentColor,
          onTap: () => _pickEndDate(context),
          onClear: onClearEnd,
        );

        if (constraints.maxWidth < breakpoint) {
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

class _ExpenseDateRangeField extends StatelessWidget {
  const _ExpenseDateRangeField({
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
          floatingLabelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: accentColor,
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
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: accentColor),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value == null ? 'Todas' : DateTimeTool.formatddMMyyEs(value!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: value == null ? FontWeight.w500 : FontWeight.w700,
                  color: value == null ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (value != null && onClear != null)
              IconButton(
                tooltip: 'Limpiar $label',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                splashRadius: 20,
              )
            else
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
