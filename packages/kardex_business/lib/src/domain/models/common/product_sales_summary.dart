class ProductSalesSummary {
  final String productId;
  final int totalQuantity;
  final int totalBonQuantity;
  final int total;
  final int invoiceCount;

  const ProductSalesSummary({
    required this.productId,
    required this.totalQuantity,
    required this.totalBonQuantity,
    required this.total,
    required this.invoiceCount,
  });

  int get totalUnits => totalQuantity + totalBonQuantity;

  factory ProductSalesSummary.fromJson(Map<String, dynamic> json) => ProductSalesSummary(
    productId: json['productId'] ?? '',
    totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
    totalBonQuantity: (json['totalBonQuantity'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? 0,
    invoiceCount: (json['invoiceCount'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'totalQuantity': totalQuantity,
    'totalBonQuantity': totalBonQuantity,
    'total': total,
    'invoiceCount': invoiceCount,
  };
}
