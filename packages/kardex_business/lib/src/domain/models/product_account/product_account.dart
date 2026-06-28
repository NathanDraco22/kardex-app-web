class ProductAccountInDb {
  ProductAccountInDb({
    required this.productId,
    required this.branchId,
    required this.currentStock,
    this.promiseStock = 0,
    required this.averageCost,
    required this.lastCost,
    required this.maximumCost,
    required this.createdAt,
    this.updatedAt,
  });

  final String productId;
  final String branchId;
  final int currentStock;
  final int promiseStock;
  final int averageCost;
  final int lastCost;
  final int maximumCost;
  final DateTime createdAt;
  final DateTime? updatedAt;

  int get availableStock => currentStock - promiseStock;
  double get averageCostMoney => averageCost / 100;
  double get lasCostMoeny => lastCost / 100;

  factory ProductAccountInDb.fromJson(Map<String, dynamic> json) {
    return ProductAccountInDb(
      productId: json['productId'] as String,
      branchId: json['branchId'] as String,
      currentStock: json['currentStock'] as int,
      promiseStock: json['promiseStock'] as int? ?? 0,
      averageCost: json['averageCost'] as int,
      lastCost: json['lastCost'] as int,
      maximumCost: json['maximumCost'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'branchId': branchId,
      'currentStock': currentStock,
      'promiseStock': promiseStock,
      'averageCost': averageCost,
      'lastCost': lastCost,
      'maximumCost': maximumCost,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}
