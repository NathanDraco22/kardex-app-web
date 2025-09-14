import '../product_account/product_account.dart';
import '../product_sale_profile/product_sale_profile_model.dart';

class BaseProduct {
  final String name;
  final String? description;
  final String? code;
  final String brandName;
  final String unitName;
  final String? categoryName;
  final List<String> tags;
  final bool hasIva;
  final bool isActive;

  BaseProduct({
    required this.name,
    this.description,
    this.code,
    required this.brandName,
    required this.unitName,
    required this.categoryName,
    required this.tags,
    required this.hasIva,
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
      hasIva: json['hasIva'] as bool,
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
    required super.hasIva,
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
      hasIva: json['hasIva'] as bool,
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
  final bool? hasIva;
  final bool? isActive;

  UpdateProduct({
    this.name,
    this.description,
    this.code,
    this.brandName,
    this.unitName,
    this.categoryName,
    this.tags,
    this.hasIva,
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
      hasIva: json['hasIva'] as bool?,
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
      'hasIva': hasIva,
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
    required super.hasIva,
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
      hasIva: json['hasIva'] as bool,
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

class ProductInDbInBranch extends ProductInDb {
  final ProductAccountInDb account;
  final ProductSaleProfileInDb saleProfile;

  ProductInDbInBranch({
    required super.id,
    required super.name,
    super.description,
    super.code,
    required super.brandName,
    required super.unitName,
    super.categoryName,
    required super.tags,
    required super.hasIva,
    super.isActive,
    super.isDeleted,
    required super.createdAt,
    super.updatedAt,
    required this.account,
    required this.saleProfile,
  });

  factory ProductInDbInBranch.fromJson(Map<String, dynamic> json) {
    return ProductInDbInBranch(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      code: json['code'],
      brandName: json['brandName'],
      unitName: json['unitName'],
      categoryName: json['categoryName'],
      tags: List<String>.from(json['tags']),
      hasIva: json['hasIva'],
      isActive: json['isActive'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      account: ProductAccountInDb.fromJson(json['account']),
      saleProfile: ProductSaleProfileInDb.fromJson(json['saleProfile']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['account'] = account.toJson();
    data['saleProfile'] = saleProfile.toJson();
    return data;
  }
}
