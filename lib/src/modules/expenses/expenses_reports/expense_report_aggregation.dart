import 'package:kardex_business/kardex_business.dart';

/// Dimensión usada para consolidar los gastos del reporte.
enum ExpenseBreakdownDimension {
  operativeCategory,
  supplier,
}

/// Fila consolidada de un gráfico o ranking de gastos.
class ExpenseBreakdownEntry {
  const ExpenseBreakdownEntry({
    required this.label,
    required this.amount,
    required this.count,
    required this.fraction,
  });

  final String label;
  final int amount;
  final int count;

  /// Proporción sobre el total de la dimensión (0.0 a 1.0).
  final double fraction;

  double get percentage => fraction * 100;
}

/// Resultado de consolidar gastos por categoría o proveedor.
class ExpenseBreakdown {
  const ExpenseBreakdown({
    required this.dimension,
    required this.total,
    required this.count,
    required this.groupCount,
    required this.entries,
  });

  final ExpenseBreakdownDimension dimension;
  final int total;
  final int count;

  /// Cantidad real de grupos antes de agrupar el excedente en "Otros".
  final int groupCount;

  final List<ExpenseBreakdownEntry> entries;

  bool get isEmpty => entries.isEmpty;
}

/// Suma y cuenta los gastos no eliminados por [ExpenseType].
class ExpenseTypeTotals {
  const ExpenseTypeTotals({
    required this.operative,
    required this.supplier,
    required this.tax,
    required this.operativeCount,
    required this.supplierCount,
    required this.taxCount,
  });

  final int operative;
  final int supplier;
  final int tax;
  final int operativeCount;
  final int supplierCount;
  final int taxCount;

  int get total => operative + supplier + tax;

  int get count => operativeCount + supplierCount + taxCount;
}

ExpenseTypeTotals summarizeExpenseTypes(Iterable<ExpenseInDb> expenses) {
  var operative = 0;
  var supplier = 0;
  var tax = 0;
  var operativeCount = 0;
  var supplierCount = 0;
  var taxCount = 0;

  for (final expense in expenses) {
    if (expense.isDeleted) continue;

    switch (expense.type) {
      case ExpenseType.operative:
        operative += expense.amount;
        operativeCount++;
      case ExpenseType.supplier:
        supplier += expense.amount;
        supplierCount++;
      case ExpenseType.tax:
        tax += expense.amount;
        taxCount++;
    }
  }

  return ExpenseTypeTotals(
    operative: operative,
    supplier: supplier,
    tax: tax,
    operativeCount: operativeCount,
    supplierCount: supplierCount,
    taxCount: taxCount,
  );
}

/// Consolida los gastos por categoría operativa o por proveedor.
///
/// Devuelve como máximo [top] filas ordenadas por monto descendente; si hay
/// más grupos, el resto se agrupa en una fila "Otros". Las proporciones se
/// calculan siempre sobre el total completo de la dimensión, no sobre las
/// filas visibles.
ExpenseBreakdown buildExpenseBreakdown(
  Iterable<ExpenseInDb> expenses, {
  required ExpenseBreakdownDimension dimension,
  int top = 6,
}) {
  final amounts = <String, int>{};
  final counts = <String, int>{};
  var total = 0;
  var count = 0;

  for (final expense in expenses) {
    if (expense.isDeleted) continue;

    final matchesDimension = switch (dimension) {
      ExpenseBreakdownDimension.operativeCategory => expense.type == ExpenseType.operative,
      ExpenseBreakdownDimension.supplier => expense.type == ExpenseType.supplier,
    };
    if (!matchesDimension) continue;

    final label = _labelFor(expense, dimension);
    amounts[label] = (amounts[label] ?? 0) + expense.amount;
    counts[label] = (counts[label] ?? 0) + 1;
    total += expense.amount;
    count++;
  }

  final sorted = amounts.entries.toList()
    ..sort((a, b) {
      final byAmount = b.value.compareTo(a.value);
      return byAmount != 0 ? byAmount : a.key.compareTo(b.key);
    });

  final limit = top <= 0 ? sorted.length : top;
  final entries = <ExpenseBreakdownEntry>[
    for (final entry in sorted.take(limit))
      ExpenseBreakdownEntry(
        label: entry.key,
        amount: entry.value,
        count: counts[entry.key] ?? 0,
        fraction: total == 0 ? 0 : entry.value / total,
      ),
  ];

  if (sorted.length > limit) {
    var otherAmount = 0;
    var otherCount = 0;
    for (final entry in sorted.skip(limit)) {
      otherAmount += entry.value;
      otherCount += counts[entry.key] ?? 0;
    }
    entries.add(
      ExpenseBreakdownEntry(
        label: 'Otros',
        amount: otherAmount,
        count: otherCount,
        fraction: total == 0 ? 0 : otherAmount / total,
      ),
    );
  }

  return ExpenseBreakdown(
    dimension: dimension,
    total: total,
    count: count,
    groupCount: sorted.length,
    entries: entries,
  );
}

String _labelFor(
  ExpenseInDb expense,
  ExpenseBreakdownDimension dimension,
) {
  switch (dimension) {
    case ExpenseBreakdownDimension.operativeCategory:
      final category = expense.category.trim();
      return category.isEmpty ? 'Sin categoría' : category;
    case ExpenseBreakdownDimension.supplier:
      final supplier = expense.supplierName.trim();
      return supplier.isEmpty ? 'Proveedor desconocido' : supplier;
  }
}
