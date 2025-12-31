class EntryItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int cost;
  final int quantity;
  final int? expirationDate;

  EntryItem({
    required this.productId,
    required this.productName,
    required this.cost,
    required this.quantity,
    this.expirationDate,
    this.code,
    this.brandName,
    this.unitName,
  });

  factory EntryItem.fromJson(Map<String, dynamic> json) {
    return EntryItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      cost: json['cost'] as int,
      quantity: json['quantity'] as int,
      expirationDate: json['expirationDate'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'cost': cost,
      'quantity': quantity,
      'expirationDate': expirationDate,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
    };
  }
}
