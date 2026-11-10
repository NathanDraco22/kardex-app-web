import 'package:kardex_business/src/tools/unit_display_formatter.dart';

class TransferItem {
  final String id;
  final String name;
  final String unitName;
  final String brandName;
  final String? code;
  final String? categoryName;
  final int quantity;
  final int cost;
  final int conversionFactor;

  /// Unidad comercial seleccionada al momento de la transferencia.
  final String? selectedUnitName;

  /// Unidad estándar de la escala (Libra, Litro, Metro, Caja...).
  final String? standardUnitName;

  /// Factor de la unidad estándar respecto a la unidad base.
  final int? standardUnitFactor;

  final int? expirationDate;
  final int salePrice;
  final int salePrice2;
  final int salePrice3;
  final int salePrice4;

  TransferItem({
    required this.id,
    required this.name,
    required this.unitName,
    required this.brandName,
    this.code,
    this.categoryName,
    required this.quantity,
    required this.cost,
    this.conversionFactor = 1,
    this.selectedUnitName,
    this.standardUnitName,
    this.standardUnitFactor,
    this.expirationDate,
    required this.salePrice,
    required this.salePrice2,
    required this.salePrice3,
    required this.salePrice4,
  });

  UnitDisplayValue get displayQuantity =>
      UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: quantity,
        conversionFactor: conversionFactor,
        selectedUnitName: selectedUnitName ?? unitName,
        standardUnitName: standardUnitName,
        standardUnitFactor: standardUnitFactor,
      );

  String get formattedDisplayQuantity => displayQuantity.quantityText;

  String get displayUnitName => displayQuantity.unitName;

  int get displayUnitFactor => displayQuantity.usedStandardFallback
      ? (standardUnitFactor ?? conversionFactor)
      : conversionFactor;

  /// Costo comercial en la unidad que se muestra. `cost` está en unidad base.
  int get displayUnitCost => cost * displayUnitFactor;

  factory TransferItem.fromJson(Map<String, dynamic> json) => TransferItem(
    id: json['id'] as String,
    name: json['name'] as String,
    unitName: json['unitName'] as String,
    brandName: json['brandName'] as String,
    code: json['code'] as String?,
    categoryName: json['categoryName'] as String?,
    quantity: json['quantity'] as int,
    cost: (json['cost'] as num).toInt(),
    conversionFactor: json['conversionFactor'] as int? ?? 1,
    selectedUnitName: json['selectedUnitName'] as String?,
    standardUnitName: json['standardUnitName'] as String?,
    standardUnitFactor: (json['standardUnitFactor'] as num?)?.toInt(),
    expirationDate: json['expirationDate'] as int?,
    salePrice: (json['salePrice'] as num).toInt(),
    salePrice2: (json['salePrice2'] as num).toInt(),
    salePrice3: (json['salePrice3'] as num).toInt(),
    salePrice4: (json['salePrice4'] as num? ?? 0).toInt(),
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'unitName': unitName,
      'brandName': brandName,
      'code': code,
      'categoryName': categoryName,
      'quantity': quantity,
      'cost': cost,
      'conversionFactor': conversionFactor,
      'expirationDate': expirationDate,
      'salePrice': salePrice,
      'salePrice2': salePrice2,
      'salePrice3': salePrice3,
      'salePrice4': salePrice4,
    };
    if (selectedUnitName != null && selectedUnitName!.isNotEmpty) {
      data['selectedUnitName'] = selectedUnitName;
    }
    if (standardUnitName != null && standardUnitName!.isNotEmpty) {
      data['standardUnitName'] = standardUnitName;
    }
    if (standardUnitFactor != null) {
      data['standardUnitFactor'] = standardUnitFactor;
    }
    return data;
  }
}
