class BaseProductPrice {
  final String name;

  BaseProductPrice({required this.name});

  factory BaseProductPrice.fromJson(Map<String, dynamic> json) {
    return BaseProductPrice(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CreateProductPrice extends BaseProductPrice {
  CreateProductPrice({required super.name});

  factory CreateProductPrice.fromJson(Map<String, dynamic> json) {
    return CreateProductPrice(
      name: json['name'] as String,
    );
  }
}

class UpdateProductPrice {
  final String? name;

  UpdateProductPrice({this.name});

  factory UpdateProductPrice.fromJson(Map<String, dynamic> json) {
    return UpdateProductPrice(
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name};
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ProductPriceInDb extends BaseProductPrice {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductPriceInDb({
    required this.id,
    required super.name,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductPriceInDb.fromJson(Map<String, dynamic> json) {
    return ProductPriceInDb(
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
