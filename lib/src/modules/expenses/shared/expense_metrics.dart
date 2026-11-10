import 'package:kardex_business/kardex_business.dart';

import 'expense_status_ui.dart';

/// Resumen inmutable de los gastos visibles en una lista.
///
/// Todos los montos están expresados en centavos, igual que [ExpenseInDb.amount].
class ExpenseMetrics {
  const ExpenseMetrics({
    required this.total,
    required this.paid,
    required this.pending,
    required this.overdueAmount,
    required this.count,
    required this.paidCount,
    required this.pendingCount,
    required this.overdueCount,
  });

  /// Monto total registrado (excluye únicamente eliminados).
  final int total;

  /// Monto pagado.
  final int paid;

  /// Monto pendiente (borradores, abiertos y pagos parciales).
  final int pending;

  /// Monto de los gastos vencidos.
  final int overdueAmount;

  /// Cantidad de registros considerados (excluye eliminados).
  final int count;

  /// Cantidad de registros pagados.
  final int paidCount;

  /// Cantidad de registros pendientes.
  final int pendingCount;

  /// Cantidad de registros vencidos.
  final int overdueCount;

  factory ExpenseMetrics.fromExpenses(
    Iterable<ExpenseInDb> expenses, {
    DateTime? now,
  }) {
    var total = 0;
    var paid = 0;
    var pending = 0;
    var overdueAmount = 0;
    var count = 0;
    var paidCount = 0;
    var pendingCount = 0;
    var overdueCount = 0;

    for (final expense in expenses) {
      if (expense.isDeleted) continue;

      count++;
      total += expense.amount;

      switch (expense.status) {
        case ExpenseStatus.paid:
          paid += expense.amount;
          paidCount++;
        case ExpenseStatus.draft:
        case ExpenseStatus.open:
        case ExpenseStatus.partiallyPaid:
          pending += expense.amount;
          pendingCount++;
        case ExpenseStatus.cancelled:
          break;
      }

      if (isExpenseOverdue(expense, now: now)) {
        overdueAmount += expense.amount;
        overdueCount++;
      }
    }

    return ExpenseMetrics(
      total: total,
      paid: paid,
      pending: pending,
      overdueAmount: overdueAmount,
      count: count,
      paidCount: paidCount,
      pendingCount: pendingCount,
      overdueCount: overdueCount,
    );
  }
}
