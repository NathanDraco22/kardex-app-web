class ProductAccountInDb {
  final String productId;
  final String branchId;
  final int currentStock;
  final int averageCost;
  final int lastCost;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductAccountInDb({
    required this.productId,
    required this.branchId,
    required this.currentStock,
    required this.averageCost,
    required this.lastCost,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductAccountInDb.fromJson(Map<String, dynamic> json) => ProductAccountInDb(
    productId: json['productId'],
    branchId: json['branchId'],
    currentStock: json['currentStock'],
    averageCost: json['averageCost'],
    lastCost: json['lastCost'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'branchId': branchId,
    'currentStock': currentStock,
    'averageCost': averageCost,
    'lastCost': lastCost,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
