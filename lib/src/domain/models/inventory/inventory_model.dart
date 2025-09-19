class InventoryProduct {
  final String id;
  final String name;
  final String? description;
  final String? code;
  final String brandName;
  final String unitName;
  final String? categoryName;
  final List<String> tags;
  final bool isActive;

  InventoryProduct({
    required this.id,
    required this.name,
    this.description,
    this.code,
    required this.brandName,
    required this.unitName,
    this.categoryName,
    required this.tags,
    this.isActive = true,
  });

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    return InventoryProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      code: json['code'] as String?,
      brandName: json['brandName'] as String,
      unitName: json['unitName'] as String,
      categoryName: json['categoryName'] as String?,
      tags: List<String>.from(json['tags'] as List),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
      'categoryName': categoryName,
      'tags': tags,
      'isActive': isActive,
    };
  }
}

// Modelo principal para el registro de inventario
class InventoryInDb {
  final String branchId;
  final InventoryProduct product;
  final int currentStock;
  final int averageCost;
  final int lastCost;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InventoryInDb({
    required this.branchId,
    required this.product,
    required this.currentStock,
    required this.averageCost,
    required this.lastCost,
    required this.createdAt,
    this.updatedAt,
  });

  int get total => currentStock * averageCost;

  factory InventoryInDb.fromJson(Map<String, dynamic> json) {
    return InventoryInDb(
      branchId: json['branchId'] as String,
      product: InventoryProduct.fromJson(json['product'] as Map<String, dynamic>),
      currentStock: json['currentStock'] as int,
      averageCost: json['averageCost'] as int,
      lastCost: json['lastCost'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'product': product.toJson(),
      'currentStock': currentStock,
      'averageCost': averageCost,
      'lastCost': lastCost,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}
