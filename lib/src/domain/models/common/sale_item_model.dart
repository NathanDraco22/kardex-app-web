enum PaymentType { cash, credit }

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
  final int quantity;
  final int bonQuantity;
  final int cost;
  final int price;
  final int subTotal;
  final int discount;
  final int total;

  SaleItem({
    required this.product,
    required this.quantity,
    this.bonQuantity = 0,
    required this.cost,
    required this.price,
    required this.subTotal,
    this.discount = 0,
    required this.total,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    product: ProductItem.fromJson(json['product']),
    quantity: json['quantity'],
    bonQuantity: json['bonQuantity'] ?? 0,
    cost: json['cost'],
    price: json['price'],
    subTotal: json['subTotal'],
    discount: json['discount'] ?? 0,
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'bonQuantity': bonQuantity,
    'cost': cost,
    'price': price,
    'subTotal': subTotal,
    'discount': discount,
    'total': total,
  };
}
