// Modelo anidado para la información del producto
class ProductInfo {
  final String id;
  final String name;
  final String? description;
  final String? code;
  final String brandName;
  final String unitName;
  final String? categoryName;

  ProductInfo({
    required this.id,
    required this.name,
    this.description,
    this.code,
    required this.brandName,
    required this.unitName,
    this.categoryName,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) => ProductInfo(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    code: json['code'],
    brandName: json['brandName'],
    unitName: json['unitName'],
    categoryName: json['categoryName'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'code': code,
    'brandName': brandName,
    'unitName': unitName,
    'categoryName': categoryName,
  };
}

// Clase base para la bitácora de vencimiento
class BaseExpirationLog {
  final ProductInfo product;
  final String branchId;
  final String? lotNumber;
  final DateTime expirationDate;

  BaseExpirationLog({
    required this.product,
    required this.branchId,
    this.lotNumber,
    required this.expirationDate,
  });

  factory BaseExpirationLog.fromJson(Map<String, dynamic> json) => BaseExpirationLog(
    product: ProductInfo.fromJson(json['product']),
    branchId: json['branchId'],
    lotNumber: json['lotNumber'],
    expirationDate: DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'branchId': branchId,
    'lotNumber': lotNumber,
    'expirationDate': expirationDate.millisecondsSinceEpoch,
  };
}

// Modelo para crear
class CreateExpirationLog extends BaseExpirationLog {
  CreateExpirationLog({
    required super.product,
    required super.branchId,
    super.lotNumber,
    required super.expirationDate,
  });

  factory CreateExpirationLog.fromJson(Map<String, dynamic> json) => CreateExpirationLog(
    product: ProductInfo.fromJson(json['product']),
    branchId: json['branchId'],
    lotNumber: json['lotNumber'],
    expirationDate: DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
  );
}

// Modelo para actualizar (vacío como en el original)
class UpdateExpirationLog {
  UpdateExpirationLog();
}

// Modelo en DB
class ExpirationLogInDb extends BaseExpirationLog {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpirationLogInDb({
    required this.id,
    required super.product,
    required super.branchId,
    super.lotNumber,
    required super.expirationDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory ExpirationLogInDb.fromJson(Map<String, dynamic> json) => ExpirationLogInDb(
    id: json['id'],
    product: ProductInfo.fromJson(json['product']),
    branchId: json['branchId'],
    lotNumber: json['lotNumber'],
    expirationDate: DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
