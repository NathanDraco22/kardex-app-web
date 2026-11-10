import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

Map<String, dynamic> _baseTotalsJson() {
  return {
    'branchId': 'branch-1',
    'receipts': <dynamic>[],
    'detailReceipts': <dynamic>[],
    'invoices': <dynamic>[],
    'detailInvoices': <dynamic>[],
  };
}

void main() {
  group('TotalsResult expenses (retrocompatibilidad)', () {
    test('sin expenses deja el campo en null y no lo serializa', () {
      final result = TotalsResult.fromJson(_baseTotalsJson());

      expect(result.expenses, isNull);
      expect(result.toJson().containsKey('expenses'), isFalse);
    });

    test('parsea totales y desglose por tipo', () {
      final result = TotalsResult.fromJson({
        ..._baseTotalsJson(),
        'expenses': {
          'total': 150000,
          'paid': 100000,
          'pending': 50000,
          'count': 7,
          'byType': [
            {
              'type': 'operative',
              'total': 90000,
              'paid': 60000,
              'pending': 30000,
              'count': 4,
            },
            {
              'type': 'supplier',
              'total': 60000,
              'paid': 40000,
              'pending': 20000,
              'count': 3,
            },
          ],
        },
      });

      final expenses = result.expenses;
      expect(expenses, isNotNull);
      expect(expenses!.total, 150000);
      expect(expenses.paid, 100000);
      expect(expenses.pending, 50000);
      expect(expenses.count, 7);
      expect(expenses.byType.length, 2);
      expect(expenses.byType.first.type, ExpenseType.operative);
      expect(expenses.byType.last.type, ExpenseType.supplier);
      expect(result.toJson()['expenses'], isA<Map<String, dynamic>>());
    });

    test('tolera tipos desconocidos', () {
      final result = TotalsResult.fromJson({
        ..._baseTotalsJson(),
        'expenses': {
          'total': 100,
          'paid': 0,
          'pending': 100,
          'count': 1,
          'byType': [
            {
              'type': 'futureType',
              'total': 100,
              'paid': 0,
              'pending': 100,
              'count': 1,
            },
          ],
        },
      });

      expect(result.expenses!.byType.single.type, isNull);
    });

    test('tolera byType ausente', () {
      final result = TotalsResult.fromJson({
        ..._baseTotalsJson(),
        'expenses': {
          'total': 0,
          'paid': 0,
          'pending': 0,
          'count': 0,
        },
      });

      expect(result.expenses, isNotNull);
      expect(result.expenses!.byType, isEmpty);
    });
  });
}
