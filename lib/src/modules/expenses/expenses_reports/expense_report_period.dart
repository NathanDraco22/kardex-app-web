import 'package:flutter/material.dart';

/// Períodos predefinidos disponibles en el reporte de gastos.
enum ExpenseReportPeriod {
  today,
  yesterday,
  last7Days,
  thisMonth,
  lastMonth,
  custom,
}

extension ExpenseReportPeriodLabel on ExpenseReportPeriod {
  String get label {
    switch (this) {
      case ExpenseReportPeriod.today:
        return 'Hoy';
      case ExpenseReportPeriod.yesterday:
        return 'Ayer';
      case ExpenseReportPeriod.last7Days:
        return 'Últimos 7 días';
      case ExpenseReportPeriod.thisMonth:
        return 'Este mes';
      case ExpenseReportPeriod.lastMonth:
        return 'Mes anterior';
      case ExpenseReportPeriod.custom:
        return 'Personalizado';
    }
  }
}

/// Calcula el rango de fechas de un período predefinido.
///
/// Los rangos devueltos usan días completos (medianoche como inicio). Para
/// [ExpenseReportPeriod.custom] no existe un rango implícito: se devuelve el
/// día de [now] como valor seguro mientras la vista aplica la selección real.
DateTimeRange rangeFor(ExpenseReportPeriod period, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);

  switch (period) {
    case ExpenseReportPeriod.today:
      return DateTimeRange(start: today, end: today);
    case ExpenseReportPeriod.yesterday:
      final yesterday = today.subtract(const Duration(days: 1));
      return DateTimeRange(start: yesterday, end: yesterday);
    case ExpenseReportPeriod.last7Days:
      return DateTimeRange(
        start: today.subtract(const Duration(days: 6)),
        end: today,
      );
    case ExpenseReportPeriod.thisMonth:
      return DateTimeRange(
        start: DateTime(reference.year, reference.month),
        end: today,
      );
    case ExpenseReportPeriod.lastMonth:
      final lastMonthEnd = DateTime(reference.year, reference.month).subtract(
        const Duration(days: 1),
      );
      return DateTimeRange(
        start: DateTime(lastMonthEnd.year, lastMonthEnd.month),
        end: lastMonthEnd,
      );
    case ExpenseReportPeriod.custom:
      return DateTimeRange(start: today, end: today);
  }
}

/// Ajusta el inicio de un rango manteniendo el fin si sigue siendo válido.
///
/// Si el nuevo inicio queda después del fin actual, el fin se mueve al mismo
/// día para no dejar un rango invertido.
DateTimeRange rangeWithStart(DateTimeRange current, DateTime start) {
  final normalizedStart = DateTime(start.year, start.month, start.day);
  final normalizedEnd = DateTime(
    current.end.year,
    current.end.month,
    current.end.day,
  );

  return DateTimeRange(
    start: normalizedStart,
    end: normalizedStart.isAfter(normalizedEnd) ? normalizedStart : normalizedEnd,
  );
}

/// Ajusta el fin de un rango manteniendo el inicio si sigue siendo válido.
///
/// Si el nuevo fin queda antes del inicio actual, el inicio se mueve al mismo
/// día para no dejar un rango invertido.
DateTimeRange rangeWithEnd(DateTimeRange current, DateTime end) {
  final normalizedStart = DateTime(
    current.start.year,
    current.start.month,
    current.start.day,
  );
  final normalizedEnd = DateTime(end.year, end.month, end.day);

  return DateTimeRange(
    start: normalizedEnd.isBefore(normalizedStart) ? normalizedEnd : normalizedStart,
    end: normalizedEnd,
  );
}
