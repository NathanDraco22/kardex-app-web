import 'inventory_model.dart';

class Discount {
  String name;
  int percentValue;
  bool autoApply;
  bool isActive;

  Discount({
    required this.name,
    required this.percentValue,
    this.autoApply = false,
    required this.isActive,
  });

  factory Discount.defaultDiscount() => Discount(
    name: '',
    percentValue: 0,
    isActive: true,
  );

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      name: json['name'] as String,
      percentValue: json['percentValue'] as int,
      autoApply: json['autoApply'] as bool? ?? false,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentValue': percentValue,
      'autoApply': autoApply,
      'isActive': isActive,
    };
  }
}

// Clase base para el perfil de venta de producto
class BaseProductSaleProfile {
  final String branchId;
  final String productId;
  int salePrice;
  final List<Discount> discounts;

  BaseProductSaleProfile({
    required this.branchId,
    required this.productId,
    required this.salePrice,
    this.discounts = const [],
  });

  factory BaseProductSaleProfile.fromJson(Map<String, dynamic> json) {
    return BaseProductSaleProfile(
      branchId: json['branchId'] as String,
      productId: json['productId'] as String,
      salePrice: json['salePrice'] as int,
      discounts:
          (json['discounts'] as List<dynamic>?)?.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'productId': productId,
      'salePrice': salePrice,
      'discounts': discounts.map((e) => e.toJson()).toList(),
    };
  }
}

// Modelo para crear
class CreateProductSaleProfile extends BaseProductSaleProfile {
  CreateProductSaleProfile({
    required super.branchId,
    required super.productId,
    required super.salePrice,
    super.discounts,
  });

  factory CreateProductSaleProfile.fromJson(Map<String, dynamic> json) {
    return CreateProductSaleProfile(
      branchId: json['branchId'] as String,
      productId: json['productId'] as String,
      salePrice: json['salePrice'] as int,
      discounts:
          (json['discounts'] as List<dynamic>?)?.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
    );
  }
}

// Modelo para actualizar
class UpdateProductSaleProfile {
  final int? salePrice;
  final List<Discount>? discounts;

  UpdateProductSaleProfile({this.salePrice, this.discounts});

  factory UpdateProductSaleProfile.fromJson(Map<String, dynamic> json) {
    return UpdateProductSaleProfile(
      salePrice: json['salePrice'] as int?,
      discounts: (json['discounts'] as List<dynamic>?)
          ?.map((e) => Discount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'salePrice': salePrice,
      'discounts': discounts?.map((e) => e.toJson()).toList(),
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

// Modelo en DB (simple)
class ProductSaleProfileInDb extends BaseProductSaleProfile {
  final DateTime? updatedAt;

  ProductSaleProfileInDb({
    required super.branchId,
    required super.productId,
    required super.salePrice,
    super.discounts,
    this.updatedAt,
  });

  factory ProductSaleProfileInDb.fromJson(Map<String, dynamic> json) {
    return ProductSaleProfileInDb(
      branchId: json['branchId'] as String,
      productId: json['productId'] as String,
      salePrice: json['salePrice'] as int,
      discounts:
          (json['discounts'] as List<dynamic>?)?.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['updated_at'] = updatedAt?.toIso8601String();
    return data;
  }
}

// Modelo en DB (con detalles de producto y cuenta)
// NOTA: Los modelos InventoryProduct y ProductAccount se asumen ya definidos.
class ProductSaleProfileInDbWithProduct extends BaseProductSaleProfile {
  final DateTime? updatedAt;
  final InventoryProduct product;
  final ProductAccount account;

  ProductSaleProfileInDbWithProduct({
    required super.branchId,
    required super.productId,
    required super.salePrice,
    super.discounts,
    this.updatedAt,
    required this.product,
    required this.account,
  });

  factory ProductSaleProfileInDbWithProduct.fromJson(Map<String, dynamic> json) {
    return ProductSaleProfileInDbWithProduct(
      branchId: json['branchId'] as String,
      productId: json['productId'] as String,
      salePrice: json['salePrice'] as int,
      discounts:
          (json['discounts'] as List<dynamic>?)?.map((e) => Discount.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      product: InventoryProduct.fromJson(json['product'] as Map<String, dynamic>),
      account: ProductAccount.fromJson(json['account'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['updated_at'] = updatedAt?.toIso8601String();
    data['product'] = product.toJson();
    data['account'] = account.toJson();
    return data;
  }

  /// Crea una copia de la instancia actual con los nuevos valores proporcionados
  ProductSaleProfileInDbWithProduct copyWith({
    String? branchId,
    String? productId,
    int? salePrice,
    List<Discount>? discounts,
    DateTime? updatedAt,
    InventoryProduct? product,
    ProductAccount? account,
  }) {
    return ProductSaleProfileInDbWithProduct(
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      salePrice: salePrice ?? this.salePrice,
      discounts: discounts ?? this.discounts,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
      account: account ?? this.account,
    );
  }
}
