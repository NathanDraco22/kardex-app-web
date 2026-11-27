import 'package:kardex_business/src/domain/models/common/discount_type.dart';
import 'package:kardex_business/src/domain/models/product/product_type.dart';
import 'package:kardex_business/src/tools/unit_conversion_tool.dart';
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
  final ProductType productType;
  final int priceUnitFactor;

  ProductItem({
    required this.id,
    required this.name,
    required this.unitName,
    this.brandName = "",
    this.code,
    this.categoryName,
    this.tags = const [],
    this.productType = ProductType.item,
    this.priceUnitFactor = 1,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final rawPriceFactor = (json['priceUnitFactor'] as num?)?.toInt() ?? 1;
    return ProductItem(
      id: json['id'],
      name: json['name'],
      unitName: json['unitName'],
      brandName: json['brandName'] as String? ?? "",
      code: json['code'],
      categoryName: json['categoryName'],
      tags: List<String>.from(json['tags'] ?? []),
      productType: ProductType.fromJson(json['productType']),
      priceUnitFactor: rawPriceFactor < 1 ? 1 : rawPriceFactor,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unitName': unitName,
    'brandName': brandName,
    'code': code,
    'categoryName': categoryName,
    'tags': tags,
    'productType': productType.apiValue,
    'priceUnitFactor': priceUnitFactor < 1 ? 1 : priceUnitFactor,
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
  final DiscountType? discountType;
  final int discountPercentage;
  final int totalDiscount;
  final int total;
  final int conversionFactor;
  final int priceUnitFactor;

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
    this.discountType,
    this.discountPercentage = 0,
    this.totalDiscount = 0,
    required this.total,
    this.conversionFactor = 1,
    this.priceUnitFactor = 1,
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

  int get displayUnitPrice => UnitConversionTool.toDisplayPriceOrCost(
    price,
    displayUnitFactor,
    priceUnitFactor: priceUnitFactor,
  );

  int get lineCost => UnitConversionTool.calculateLineTotal(
    cost,
    quantity + bonQuantity,
    priceUnitFactor: priceUnitFactor,
  );

  double get displayBonQuantity => conversionFactor <= 1
      ? bonQuantity.toDouble()
      : bonQuantity / conversionFactor;

  String get formattedDisplayBonQuantity => _bonQuantityDisplay.quantityText;

  double get effectiveTotalDisplayQuantity {
    final factor = displayUnitFactor <= 1 ? 1 : displayUnitFactor;
    return (quantity + bonQuantity) / factor;
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    final pct = json['discountPercentage'] ?? 0;
    final totalDisc = json['totalDiscount'] ?? 0;
    final parsedType =
        DiscountType.tryFromApi(json['discountType'] as String?) ??
        (pct > 0
            ? DiscountType.percentage
            : (totalDisc > 0 ? DiscountType.amount : null));

    return SaleItem(
      product: ProductItem.fromJson(json['product']),
      selectedPrice: json['selectedPrice'],
      quantity: json['quantity'],
      bonQuantity: json['bonQuantity'] ?? 0,
      cost: json['cost'],
      price: json['price'],
      subTotal: json['subTotal'],
      discountType: parsedType,
      discountPercentage: pct,
      totalDiscount: totalDisc,
      total: json['total'],
      conversionFactor: json['conversionFactor'] ?? 1,
      priceUnitFactor:
          ((json['priceUnitFactor'] as num?)?.toInt() ?? 1).clamp(1, 1 << 30),
      selectedUnitName: json['selectedUnitName'] as String?,
      standardUnitName: json['standardUnitName'] as String?,
      standardUnitFactor: json['standardUnitFactor'] as int?,
      invoiceItemIndex: json['invoiceItemIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'product': product.toJson(),
      'selectedPrice': selectedPrice,
      'quantity': quantity,
      'bonQuantity': bonQuantity,
      'cost': cost,
      'price': price,
      'subTotal': subTotal,
      if (discountType != null) 'discountType': discountType!.apiValue,
      'discountPercentage': discountPercentage,
      'totalDiscount': totalDiscount,
      'total': total,
      'conversionFactor': conversionFactor,
      'priceUnitFactor': priceUnitFactor < 1 ? 1 : priceUnitFactor,
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
