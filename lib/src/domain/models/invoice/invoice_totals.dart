class InvoiceTotals {
  InvoiceTotals({
    required this.total,
    required this.totalCost,
  });

  int total;
  int totalCost;

  factory InvoiceTotals.fromJson(Map<String, dynamic> map) {
    return InvoiceTotals(
      total: map['total'] ?? 0,
      totalCost: map['totalCost'] ?? 0,
    );
  }
}
