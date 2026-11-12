import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_metrics.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_status_ui.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('ExpenseMetrics.fromExpenses', () {
    final now = DateTime(2026, 11, 10, 12);

    test('agrupa montos y conteos por estado y vencimiento', () {
      final expenses = [
        _expense(
          id: 'paid',
          amount: 10000,
          status: ExpenseStatus.paid,
          expirationDate: DateTime(2026, 11, 9),
        ),
        _expense(
          id: 'overdue',
          amount: 5000,
          status: ExpenseStatus.open,
          expirationDate: DateTime(2026, 11, 9),
        ),
        _expense(
          id: 'pending',
          amount: 3000,
          status: ExpenseStatus.open,
          expirationDate: DateTime(2026, 11, 11),
        ),
        _expense(
          id: 'cancelled',
          amount: 2000,
          status: ExpenseStatus.cancelled,
          expirationDate: DateTime(2026, 11, 9),
        ),
        _expense(
          id: 'deleted',
          amount: 9999,
          status: ExpenseStatus.open,
          isDeleted: true,
        ),
      ];

      final metrics = ExpenseMetrics.fromExpenses(expenses, now: now);

      expect(metrics.total, 20000);
      expect(metrics.paid, 10000);
      expect(metrics.pending, 8000);
      expect(metrics.overdueAmount, 5000);
      expect(metrics.count, 4);
      expect(metrics.paidCount, 1);
      expect(metrics.pendingCount, 2);
      expect(metrics.overdueCount, 1);
    });

    test('incluye borradores y pagos parciales en el monto pendiente', () {
      final expenses = [
        _expense(id: 'draft', amount: 1000, status: ExpenseStatus.draft),
        _expense(id: 'open', amount: 2000, status: ExpenseStatus.open),
        _expense(id: 'partial', amount: 3000, status: ExpenseStatus.partiallyPaid),
        _expense(id: 'paid', amount: 4000, status: ExpenseStatus.paid),
      ];

      final metrics = ExpenseMetrics.fromExpenses(expenses, now: now);

      expect(metrics.pending, 6000);
      expect(metrics.pendingCount, 3);
      expect(metrics.paid, 4000);
      expect(metrics.total, 10000);
    });

    test('un gasto que vence hoy no se considera vencido', () {
      final expense = _expense(
        id: 'today',
        amount: 1500,
        status: ExpenseStatus.open,
        expirationDate: DateTime(2026, 11, 10),
      );

      expect(isExpenseOverdue(expense, now: now), isFalse);
    });

    test('un gasto pagado o cancelado nunca se considera vencido', () {
      final paid = _expense(
        id: 'paid',
        amount: 1500,
        status: ExpenseStatus.paid,
        expirationDate: DateTime(2026, 11, 1),
      );
      final cancelled = _expense(
        id: 'cancelled',
        amount: 1500,
        status: ExpenseStatus.cancelled,
        expirationDate: DateTime(2026, 11, 1),
      );

      expect(isExpenseOverdue(paid, now: now), isFalse);
      expect(isExpenseOverdue(cancelled, now: now), isFalse);
    });
  });
}

ExpenseInDb _expense({
  required String id,
  required int amount,
  required ExpenseStatus status,
  DateTime? expirationDate,
  bool isDeleted = false,
}) {
  return ExpenseInDb(
    id: id,
    isDeleted: isDeleted,
    createdAt: DateTime(2026, 11, 10, 8),
    branchId: 'branch-1',
    amount: amount,
    category: 'Servicios',
    date: DateTime(2026, 11, 10).millisecondsSinceEpoch,
    dateId: '2026-11-10',
    status: status,
    type: ExpenseType.operative,
    expirationDate: expirationDate?.millisecondsSinceEpoch,
    createdBy: const UserInfo(id: 'user-1', name: 'Usuario'),
  );
}
