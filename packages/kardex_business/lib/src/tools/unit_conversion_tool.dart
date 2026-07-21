import 'dart:math';

class UnitConversionTool {
  static int ensureSafeFactor(int factor) => max(factor, 1);

  static int toBaseQuantity(int displayQuantity, int conversionFactor) {
    return displayQuantity * ensureSafeFactor(conversionFactor);
  }

  static int toBaseCost(int unitaryCost, int conversionFactor) {
    return unitaryCost ~/ ensureSafeFactor(conversionFactor);
  }

  static num toDisplayQuantity(int baseQuantity, int conversionFactor) {
    return baseQuantity / ensureSafeFactor(conversionFactor);
  }

  static String formatDisplayStock(int stock, int conversionFactor) {
    final safeFactor = ensureSafeFactor(conversionFactor);
    final val = stock / safeFactor;
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  static String resolveUnitName(String selectedUnitName, String fallbackUnitName) {
    return selectedUnitName.isNotEmpty ? selectedUnitName : fallbackUnitName;
  }

  static int convertToBaseUnit(int quantity, int conversionFactor) {
    return quantity * ensureSafeFactor(conversionFactor);
  }

  static num convertToDisplayUnit(int baseQuantity, int conversionFactor) {
    return toDisplayQuantity(baseQuantity, conversionFactor);
  }
}
