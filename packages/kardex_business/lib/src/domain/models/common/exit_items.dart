import 'package:kardex_business/src/tools/unit_display_formatter.dart';

class AdjustExitItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int cost; // Historical cost at the time of exit
  final int quantity;
  final int conversionFactor;
  final String? standardUnitName;
  final int? standardUnitFactor;

  AdjustExitItem({
    required this.productId,
    required this.productName,
    required this.cost,
    required this.quantity,
    this.conversionFactor = 1,
    this.standardUnitName,
    this.standardUnitFactor,
    this.code,
    this.brandName,
    this.unitName,
  });

  UnitDisplayValue get displayQuantity =>
      UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: quantity.abs(),
        conversionFactor: conversionFactor,
        selectedUnitName: unitName,
        standardUnitName: standardUnitName,
        standardUnitFactor: standardUnitFactor,
      );

  String get formattedDisplayQuantity => displayQuantity.quantityText;

  String get displayUnitName => displayQuantity.unitName;

  factory AdjustExitItem.fromJson(Map<String, dynamic> json) {
    return AdjustExitItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      cost: json['cost'] as int,
      quantity: json['quantity'] as int,
      conversionFactor: json['conversionFactor'] as int? ?? 1,
      standardUnitName: json['standardUnitName'] as String?,
      standardUnitFactor: json['standardUnitFactor'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'cost': cost,
      'quantity': quantity,
      'conversionFactor': conversionFactor,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
    };
    if (standardUnitName != null) {
      data['standardUnitName'] = standardUnitName;
    }
    if (standardUnitFactor != null) {
      data['standardUnitFactor'] = standardUnitFactor;
    }
    return data;
  }
}
