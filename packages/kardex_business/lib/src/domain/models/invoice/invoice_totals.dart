class InvoiceTotals {
  InvoiceTotals({
    this.paymentType,
    required this.total,
    required this.totalCost,
    this.count = 0,
  });

  String? paymentType;
  int total;
  int totalCost;
  int count;

  String get displayPaymentType {
    if (paymentType == null) return "Sin especificar";
    switch (paymentType) {
      case "cash":
        return "Efectivo";
      case "transfer":
        return "Transferencia";
      case "card":
        return "Tarjeta";
      case "check":
        return "Cheque";
      case "credit":
        return "Crédito";
      case "other":
        return "Otro";
      default:
        return "Sin especificar";
    }
  }

  factory InvoiceTotals.fromJson(Map<String, dynamic> map) {
    return InvoiceTotals(
      paymentType: map['paymentType'],
      total: map['total'] ?? 0,
      totalCost: map['totalCost'] ?? 0,
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (paymentType != null) 'paymentType': paymentType,
      'total': total,
      'totalCost': totalCost,
      'count': count,
    };
  }
}
