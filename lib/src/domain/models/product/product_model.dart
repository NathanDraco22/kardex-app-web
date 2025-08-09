class BaseProduct {
  final String name;
  final String? description;
  final String? code;
  final String brandName;
  final String unitName;
  final String? categoryName;
  final List<String> tags;
  final bool isActive;

  BaseProduct({
    required this.name,
    this.description,
    this.code,
    required this.brandName,
    required this.unitName,
    required this.categoryName,
    required this.tags,
    this.isActive = true,
  });

  factory BaseProduct.fromJson(Map<String, dynamic> json) {
    return BaseProduct(
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

class CreateProduct extends BaseProduct {
  CreateProduct({
    required super.name,
    super.description,
    super.code,
    required super.brandName,
    required super.unitName,
    required super.categoryName,
    required super.tags,
    super.isActive,
  });

  factory CreateProduct.fromJson(Map json) {
    return CreateProduct(
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
}

class UpdateProduct {
  final String? name;
  final String? description;
  final String? code;
  final String? brandName;
  final String? unitName;
  final String? categoryName;
  final List<String>? tags;
  final bool? isActive;

  UpdateProduct({
    this.name,
    this.description,
    this.code,
    this.brandName,
    this.unitName,
    this.categoryName,
    this.tags,
    this.isActive,
  });

  factory UpdateProduct.fromJson(Map json) {
    return UpdateProduct(
      name: json['name'] as String?,
      description: json['description'] as String?,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      categoryName: json['categoryName'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
      'categoryName': categoryName,
      'tags': tags,
      'isActive': isActive,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ProductInDb extends BaseProduct {
  final String id;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductInDb({
    required this.id,
    required super.name,
    super.description,
    super.code,
    required super.brandName,
    required super.unitName,
    required super.categoryName,
    required super.tags,
    super.isActive,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductInDb.fromJson(Map<String, dynamic> json) {
    return ProductInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      code: json['code'] as String?,
      brandName: json['brandName'] as String,
      unitName: json['unitName'] as String,
      categoryName: json['categoryName'] as String?,
      tags: List<String>.from(json['tags'] as List),
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });
    return data;
  }
}
