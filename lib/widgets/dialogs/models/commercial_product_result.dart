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

    if (product.extraUnits.isEmpty || resolvedUnitIndex > product.extraUnits.length) {
      resolvedUnitIndex = 0;
    }
    if (!product.showBasicUnit && product.extraUnits.isNotEmpty && resolvedUnitIndex == 0) {
      resolvedUnitIndex = 1;
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
  DiscountType? manualDiscountType;
  int manualDiscountValue = 0;
  double quantity = 0.0;
  bool roundUpLineTotals = false;
  
  int selectedUnitIndex = 0;
  int conversionFactor = 1;
  String selectedUnitName = '';

  int get baseQuantity => (quantity * conversionFactor).round();

  String get formattedQuantity => UnitConversionTool.formatQuantity(quantity);

  bool get _roundingEnabled =>
      roundUpLineTotals && InvoiceRounding.isEnabled;

  int get subTotal {
    final raw = UnitConversionTool.calculateLineTotal(
      _newPrice,
      baseQuantity,
      priceUnitFactor: product.priceUnitFactor,
    );
    return _roundingEnabled
        ? InvoiceRounding.roundUpToWholeUnit(raw)
        : raw;
  }

  int get newPrice => _newPrice;

  set newPrice(int value) {
    selectedDiscount = null;
    manualDiscountType = null;
    manualDiscountValue = 0;
    _newPrice = value;
  }

  void applyPredefinedDiscount(Discount? discount) {
    selectedDiscount = discount;
    manualDiscountType = null;
    manualDiscountValue = 0;
  }

  void applyManualDiscount(DiscountType? type, int value) {
    selectedDiscount = null;
    if (type == null || value <= 0) {
      manualDiscountType = null;
      manualDiscountValue = 0;
    } else {
      manualDiscountType = type;
      manualDiscountValue = type == DiscountType.percentage
          ? value.clamp(0, 100)
          : value.clamp(0, subTotal);
    }
  }

  void clearDiscount() {
    selectedDiscount = null;
    manualDiscountType = null;
    manualDiscountValue = 0;
  }

  DiscountType? get effectiveDiscountType {
    if (manualDiscountType != null && manualDiscountValue > 0) {
      return manualDiscountType;
    }
    if (selectedDiscount != null && selectedDiscount!.percentValue > 0) {
      return DiscountType.percentage;
    }
    return null;
  }

  int get discountPercent {
    if (manualDiscountType == DiscountType.percentage &&
        manualDiscountValue > 0) {
      return manualDiscountValue.clamp(0, 100);
    }
    if (manualDiscountType == DiscountType.amount) {
      return 0;
    }
    return selectedDiscount?.percentValue ?? 0;
  }

  int get totalDiscount {
    final raw = manualDiscountType != null && manualDiscountValue > 0
        ? DiscountType.calculateDiscountAmount(
            type: manualDiscountType,
            discountValue: manualDiscountValue,
            baseAmount: subTotal,
          )
        : DiscountType.calculateDiscountAmount(
            type: selectedDiscount != null ? DiscountType.percentage : null,
            discountValue: selectedDiscount?.percentValue ?? 0,
            baseAmount: subTotal,
          );
    return _roundingEnabled
        ? InvoiceRounding.roundDownToWholeUnit(raw)
        : raw;
  }

  int get total {
    return (subTotal - totalDiscount).clamp(0, subTotal);
  }

  CommercialProductResult copyWith({
    ProductInDbInBranch? product,
    int? newPrice,
    int? selectedPriceLevel,
    Discount? selectedDiscount,
    DiscountType? manualDiscountType,
    int? manualDiscountValue,
    double? quantity,
    int? selectedUnitIndex,
    int? conversionFactor,
    String? selectedUnitName,
    bool? roundUpLineTotals,
  }) {
    final result = CommercialProductResult(
      product: product ?? this.product,
      defaultPriceLevel: selectedPriceLevel ?? this.selectedPriceLevel,
    );

    result.roundUpLineTotals =
        roundUpLineTotals ?? this.roundUpLineTotals;
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

    if (manualDiscountType != null) {
      result.manualDiscountType = manualDiscountType;
      result.manualDiscountValue =
          manualDiscountValue ?? this.manualDiscountValue;
    } else if (newPrice == null && selectedDiscount == null) {
      result.manualDiscountType = this.manualDiscountType;
      result.manualDiscountValue = this.manualDiscountValue;
    }

    result.quantity = quantity ?? this.quantity;
    result.selectedUnitIndex = selectedUnitIndex ?? this.selectedUnitIndex;
    result.conversionFactor = conversionFactor ?? this.conversionFactor;
    result.selectedUnitName = selectedUnitName ?? this.selectedUnitName;

    return result;
  }
}
