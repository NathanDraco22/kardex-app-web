// Modelo para los detalles del producto en el perfil de venta
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

// Modelo para la información de cuenta del producto
class ProductAccount {
  final int currentStock;
  final int averageCost;
  final int lastCost;
  final int maximumCost;

  ProductAccount({
    required this.currentStock,
    required this.averageCost,
    required this.lastCost,
    required this.maximumCost,
  });

  factory ProductAccount.fromJson(Map<String, dynamic> json) {
    return ProductAccount(
      currentStock: json['currentStock'] as int,
      averageCost: json['averageCost'] as int,
      lastCost: json['lastCost'] as int,
      maximumCost: (json['maximumCost'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStock': currentStock,
      'averageCost': averageCost,
      'lastCost': lastCost,
      'maximumCost': maximumCost,
    };
  }
}
