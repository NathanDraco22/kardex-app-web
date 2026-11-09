import 'package:kardex_business/src/tools/unit_display_formatter.dart';

class EntryItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int cost;
  final int quantity;
  final int conversionFactor;
  final String? standardUnitName;
  final int? standardUnitFactor;
  final int? expirationDate;

  EntryItem({
    required this.productId,
    required this.productName,
    required this.cost,
    required this.quantity,
    this.conversionFactor = 1,
    this.standardUnitName,
    this.standardUnitFactor,
    this.expirationDate,
    this.code,
    this.brandName,
    this.unitName,
  });

  UnitDisplayValue get displayQuantity =>
      UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: quantity,
        conversionFactor: conversionFactor,
        selectedUnitName: unitName,
        standardUnitName: standardUnitName,
        standardUnitFactor: standardUnitFactor,
      );

  String get formattedDisplayQuantity => displayQuantity.quantityText;

  String get displayUnitName => displayQuantity.unitName;

  factory EntryItem.fromJson(Map<String, dynamic> json) {
    return EntryItem(
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
      expirationDate: json['expirationDate'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'cost': cost,
      'quantity': quantity,
      'conversionFactor': conversionFactor,
      'expirationDate': expirationDate,
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
