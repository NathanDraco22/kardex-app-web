class ProductStockDemand {
  final String productId;
  final String productName;
  final int totalOrdered;
  final int totalBonification;
  final int currentStock;
  final int shortage;

  ProductStockDemand({
    required this.productId,
    required this.productName,
    required this.totalOrdered,
    required this.totalBonification,
    required this.currentStock,
    required this.shortage,
  });

  factory ProductStockDemand.fromJson(Map<String, dynamic> json) => ProductStockDemand(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    totalOrdered: json['totalOrdered'] as int,
    totalBonification: json['totalBonification'] as int,
    currentStock: json['currentStock'] as int,
    shortage: json['shortage'] as int,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'totalOrdered': totalOrdered,
    'totalBonification': totalBonification,
    'currentStock': currentStock,
    'shortage': shortage,
  };
}
