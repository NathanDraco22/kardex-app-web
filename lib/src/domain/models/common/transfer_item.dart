class TransferItem {
  final String id;
  final String name;
  final String unitName;
  final String brandName;
  final String? code;
  final String? categoryName;
  final int quantity;
  final int cost;
  final int? expirationDate;
  final int salePrice;
  final int salePrice2;
  final int salePrice3;

  TransferItem({
    required this.id,
    required this.name,
    required this.unitName,
    required this.brandName,
    this.code,
    this.categoryName,
    required this.quantity,
    required this.cost,
    this.expirationDate,
    required this.salePrice,
    required this.salePrice2,
    required this.salePrice3,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) => TransferItem(
    id: json['id'] as String,
    name: json['name'] as String,
    unitName: json['unitName'] as String,
    brandName: json['brandName'] as String,
    code: json['code'] as String?,
    categoryName: json['categoryName'] as String?,
    quantity: json['quantity'] as int,
    cost: (json['cost'] as num).toInt(),
    expirationDate: json['expirationDate'] as int?,
    salePrice: (json['salePrice'] as num).toInt(),
    salePrice2: (json['salePrice2'] as num).toInt(),
    salePrice3: (json['salePrice3'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unitName': unitName,
    'brandName': brandName,
    'code': code,
    'categoryName': categoryName,
    'quantity': quantity,
    'cost': cost,
    'expirationDate': expirationDate,
    'salePrice': salePrice,
    'salePrice2': salePrice2,
    'salePrice3': salePrice3,
  };
}
