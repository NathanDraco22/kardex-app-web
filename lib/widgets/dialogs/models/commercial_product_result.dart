import 'package:kardex_business/kardex_business.dart';

class CommercialProductResult {
  CommercialProductResult({
    required this.product,
    int defaultPriceLevel = 1,
    String preferredUnitType = 'min',
  }) {
    selectedPriceLevel = defaultPriceLevel;
    final priceMap = {
      1: product.saleProfile.salePrice,
      2: product.saleProfile.salePrice2,
      3: product.saleProfile.salePrice3,
      4: product.saleProfile.salePrice4,
    };
    _newPrice = priceMap[defaultPriceLevel] ?? product.saleProfile.salePrice;

    int resolvedUnitIndex;
    if (preferredUnitType == "max" && product.wholesaleUnitIndex > 0) {
      resolvedUnitIndex = product.wholesaleUnitIndex;
    } else {
      resolvedUnitIndex = product.defaultUnitIndex;
    }

    selectedUnitIndex = resolvedUnitIndex;
    if (resolvedUnitIndex == 0) {
      conversionFactor = 1;
      selectedUnitName = product.unitName;
    } else {
      final extra = product.extraUnits[resolvedUnitIndex - 1];
      conversionFactor = extra.conversionFactor;
      selectedUnitName = extra.name;
    }
  }
  ProductInDbInBranch product;
  int _newPrice = 0;
  int selectedPriceLevel = 1;
  Discount? selectedDiscount;
  int quantity = 0;
  
  int selectedUnitIndex = 0;
  int conversionFactor = 1;
  String selectedUnitName = '';

  int get subTotal {
    return quantity * _newPrice * conversionFactor;
  }

  int get newPrice => _newPrice;

  set newPrice(int value) {
    selectedDiscount = null;
    _newPrice = value;
  }

  int get discountPercent => selectedDiscount?.percentValue ?? 0;

  int get totalDiscount {
    final decimalResult = subTotal * ((selectedDiscount?.percentValue ?? 0) / 100);
    return decimalResult.round();
  }

  int get total {
    return subTotal - totalDiscount;
  }

  CommercialProductResult copyWith({
    ProductInDbInBranch? product,
    int? newPrice,
    int? selectedPriceLevel,
    Discount? selectedDiscount,
    int? quantity,
    int? selectedUnitIndex,
    int? conversionFactor,
    String? selectedUnitName,
  }) {
    final result = CommercialProductResult(
      product: product ?? this.product,
      defaultPriceLevel: selectedPriceLevel ?? this.selectedPriceLevel,
    );

    if (newPrice != null) {
      result.newPrice = newPrice;
    } else {
      result._newPrice = _newPrice;
    }

    result.selectedPriceLevel = selectedPriceLevel ?? this.selectedPriceLevel;

    if (selectedDiscount != null) {
      result.selectedDiscount = selectedDiscount;
    } else if (newPrice == null) {
      result.selectedDiscount = this.selectedDiscount;
    }

    result.quantity = quantity ?? this.quantity;
    result.selectedUnitIndex = selectedUnitIndex ?? this.selectedUnitIndex;
    result.conversionFactor = conversionFactor ?? this.conversionFactor;
    result.selectedUnitName = selectedUnitName ?? this.selectedUnitName;

    return result;
  }
}

