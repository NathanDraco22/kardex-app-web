enum PaymentType {
  cash,
  credit,
  transfer,
  card,
  check,
  other
  ;

  String get typeLabel {
    switch (this) {
      case PaymentType.cash:
        return "Contado";
      case PaymentType.credit:
        return "Crédito";
      case PaymentType.transfer:
        return "Transferencia";
      case PaymentType.card:
        return "Tarjeta";
      case PaymentType.check:
        return "Cheque";
      case PaymentType.other:
        return "Otro";
    }
  }
}

class ProductItem {
  final String id;
  final String name;
  final String unitName;
  final String brandName;
  final String? code;
  final String? categoryName;
  final List<String> tags;

  ProductItem({
    required this.id,
    required this.name,
    required this.unitName,
    required this.brandName,
    this.code,
    this.categoryName,
    this.tags = const [],
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    id: json['id'],
    name: json['name'],
    unitName: json['unitName'],
    brandName: json['brandName'],
    code: json['code'],
    categoryName: json['categoryName'],
    tags: List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unitName': unitName,
    'brandName': brandName,
    'code': code,
    'categoryName': categoryName,
    'tags': tags,
  };
}

class SaleItem {
  final ProductItem product;
  final int selectedPrice;
  final int quantity;
  final int bonQuantity;
  final int cost;
  final int price;
  final int subTotal;
  final int discountPercentage;
  final int totalDiscount;
  final int total;

  SaleItem({
    required this.product,
    required this.selectedPrice,
    required this.quantity,
    this.bonQuantity = 0,
    required this.cost,
    required this.price,
    required this.subTotal,
    this.discountPercentage = 0,
    this.totalDiscount = 0,
    required this.total,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    product: ProductItem.fromJson(json['product']),
    selectedPrice: json['selectedPrice'],
    quantity: json['quantity'],
    bonQuantity: json['bonQuantity'] ?? 0,
    cost: json['cost'],
    price: json['price'],
    subTotal: json['subTotal'],
    discountPercentage: json['discountPercentage'] ?? 0,
    totalDiscount: json['totalDiscount'] ?? 0,
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'selectedPrice': selectedPrice,
    'quantity': quantity,
    'bonQuantity': bonQuantity,
    'cost': cost,
    'price': price,
    'subTotal': subTotal,
    'discountPercentage': discountPercentage,
    'totalDiscount': totalDiscount,
    'total': total,
  };
}
