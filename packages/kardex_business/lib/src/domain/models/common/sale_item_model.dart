import 'package:kardex_business/src/tools/unit_display_formatter.dart';

enum PaymentType {
  cash,
  credit,
  transfer,
  card,
  check,
  other;

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
  final int conversionFactor;

  /// Unidad comercial seleccionada al momento de la venta.
  final String? selectedUnitName;

  /// Unidad estándar de la escala (Libra, Litro, Metro, Caja...).
  final String? standardUnitName;

  /// Factor de la unidad estándar respecto a la unidad base.
  final int? standardUnitFactor;

  /// Índice de la línea dentro de `saleItems` de la factura original.
  /// Solo se usa en notas de crédito por devolución.
  final int? invoiceItemIndex;

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
    this.conversionFactor = 1,
    this.selectedUnitName,
    this.standardUnitName,
    this.standardUnitFactor,
    this.invoiceItemIndex,
  });

  double get displayQuantity =>
      conversionFactor <= 1 ? quantity.toDouble() : quantity / conversionFactor;

  UnitDisplayValue get _quantityDisplay =>
      UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: quantity,
        conversionFactor: conversionFactor,
        selectedUnitName: selectedUnitName ?? product.unitName,
        standardUnitName: standardUnitName,
        standardUnitFactor: standardUnitFactor,
      );

  UnitDisplayValue get _bonQuantityDisplay =>
      UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: bonQuantity,
        conversionFactor: conversionFactor,
        selectedUnitName: selectedUnitName ?? product.unitName,
        standardUnitName: standardUnitName,
        standardUnitFactor: standardUnitFactor,
      );

  String get formattedDisplayQuantity => _quantityDisplay.quantityText;

  String get displayUnitName => _quantityDisplay.unitName;

  int get displayUnitFactor => _quantityDisplay.usedStandardFallback
      ? (standardUnitFactor ?? conversionFactor)
      : conversionFactor;

  double get displayBonQuantity => conversionFactor <= 1
      ? bonQuantity.toDouble()
      : bonQuantity / conversionFactor;

  String get formattedDisplayBonQuantity => _bonQuantityDisplay.quantityText;

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
    conversionFactor: json['conversionFactor'] ?? 1,
    selectedUnitName: json['selectedUnitName'] as String?,
    standardUnitName: json['standardUnitName'] as String?,
    standardUnitFactor: json['standardUnitFactor'] as int?,
    invoiceItemIndex: json['invoiceItemIndex'] as int?,
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
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
      'conversionFactor': conversionFactor,
    };
    if (selectedUnitName != null) {
      data['selectedUnitName'] = selectedUnitName;
    }
    if (standardUnitName != null) {
      data['standardUnitName'] = standardUnitName;
    }
    if (standardUnitFactor != null) {
      data['standardUnitFactor'] = standardUnitFactor;
    }
    if (invoiceItemIndex != null) {
      data['invoiceItemIndex'] = invoiceItemIndex;
    }
    return data;
  }
}
