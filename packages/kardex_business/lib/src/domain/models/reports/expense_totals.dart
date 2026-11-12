import 'package:kardex_business/src/domain/models/expense/expense_model.dart';

class ExpenseTypeTotal {
  final ExpenseType? type;
  final int total;
  final int paid;
  final int pending;
  final int count;

  const ExpenseTypeTotal({
    this.type,
    this.total = 0,
    this.paid = 0,
    this.pending = 0,
    this.count = 0,
  });

  factory ExpenseTypeTotal.fromJson(Map<String, dynamic> map) {
    return ExpenseTypeTotal(
      type: _parseExpenseType(map['type']),
      total: (map['total'] as num?)?.toInt() ?? 0,
      paid: (map['paid'] as num?)?.toInt() ?? 0,
      pending: (map['pending'] as num?)?.toInt() ?? 0,
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type?.name, 'total': total, 'paid': paid, 'pending': pending, 'count': count};
  }
}

class ExpenseTotals {
  final int total;
  final int paid;
  final int pending;
  final int count;
  final List<ExpenseTypeTotal> byType;

  const ExpenseTotals({
    this.total = 0,
    this.paid = 0,
    this.pending = 0,
    this.count = 0,
    this.byType = const [],
  });

  factory ExpenseTotals.fromJson(Map<String, dynamic> map) {
    final rawByType = map['byType'];
    final byType = <ExpenseTypeTotal>[];
    if (rawByType is List) {
      for (final item in rawByType) {
        if (item is Map<String, dynamic>) {
          byType.add(ExpenseTypeTotal.fromJson(item));
        }
      }
    }

    return ExpenseTotals(
      total: (map['total'] as num?)?.toInt() ?? 0,
      paid: (map['paid'] as num?)?.toInt() ?? 0,
      pending: (map['pending'] as num?)?.toInt() ?? 0,
      count: (map['count'] as num?)?.toInt() ?? 0,
      byType: byType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'paid': paid,
      'pending': pending,
      'count': count,
      'byType': byType.map((e) => e.toJson()).toList(),
    };
  }
}

ExpenseType? _parseExpenseType(dynamic value) {
  if (value is! String) return null;
  for (final type in ExpenseType.values) {
    if (type.name == value) return type;
  }
  return null;
}
