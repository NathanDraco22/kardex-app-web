class AdjustExitItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int cost; // Historical cost at the time of exit
  final int quantity;

  AdjustExitItem({
    required this.productId,
    required this.productName,
    required this.cost,
    required this.quantity,
    this.code,
    this.brandName,
    this.unitName,
  });

  factory AdjustExitItem.fromJson(Map<String, dynamic> json) {
    return AdjustExitItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      cost: json['cost'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'cost': cost,
      'quantity': quantity,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
    };
  }
}
