class BaseProductCategory {
  final String name;

  BaseProductCategory({required this.name});

  factory BaseProductCategory.fromJson(Map<String, dynamic> json) {
    return BaseProductCategory(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CreateProductCategory extends BaseProductCategory {
  CreateProductCategory({required super.name});

  factory CreateProductCategory.fromJson(Map json) {
    return CreateProductCategory(
      name: json['name'] as String,
    );
  }
}

class UpdateProductCategory {
  final String? name;

  UpdateProductCategory({this.name});

  factory UpdateProductCategory.fromJson(Map json) {
    return UpdateProductCategory(
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name};
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ProductCategoryInDb extends BaseProductCategory {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductCategoryInDb({
    required this.id,
    required super.name,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductCategoryInDb.fromJson(Map json) {
    return ProductCategoryInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });
    return data;
  }
}
