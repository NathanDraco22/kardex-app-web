class ProductSalesTotal {
  String productId;
  String productName;
  int totalQuantity;
  int totalBonQuantity;
  int total;

  int get totalUnits => totalQuantity + totalBonQuantity;

  ProductSalesTotal({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.totalBonQuantity,
    required this.total,
  });

  factory ProductSalesTotal.fromJson(Map<String, dynamic> json) => ProductSalesTotal(
    productId: json['productId'],
    productName: json['productName'],
    totalQuantity: json['totalQuantity'],
    totalBonQuantity: json['totalBonQuantity'],
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'totalQuantity': totalQuantity,
    'totalBonQuantity': totalBonQuantity,
    'total': total,
  };
}
