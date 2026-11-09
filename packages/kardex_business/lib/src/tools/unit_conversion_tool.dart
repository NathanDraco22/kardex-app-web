import 'dart:math';

class UnitConversionTool {
  static int ensureSafeFactor(int factor) => max(factor, 1);

  static double minimumStep(int conversionFactor) =>
      1 / ensureSafeFactor(conversionFactor);

  static int toBaseQuantity(int displayQuantity, int conversionFactor) {
    return displayQuantity * ensureSafeFactor(conversionFactor);
  }

  static int toBaseCost(int unitaryCost, int conversionFactor) {
    return (unitaryCost / ensureSafeFactor(conversionFactor)).round();
  }

  static num toDisplayQuantity(int baseQuantity, int conversionFactor) {
    return baseQuantity / ensureSafeFactor(conversionFactor);
  }

  static String formatQuantity(num val, {int maxDecimals = 3}) {
    final d = val.toDouble();
    return d == d.roundToDouble()
        ? d.toInt().toString()
        : d.toStringAsFixed(maxDecimals).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String formatDisplayStock(int stock, int conversionFactor) {
    final safeFactor = ensureSafeFactor(conversionFactor);
    final val = stock / safeFactor;
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  static String resolveUnitName(
    String selectedUnitName,
    String fallbackUnitName,
  ) {
    return selectedUnitName.isNotEmpty ? selectedUnitName : fallbackUnitName;
  }

  static int convertToBaseUnit(int quantity, int conversionFactor) {
    return quantity * ensureSafeFactor(conversionFactor);
  }

  static num convertToDisplayUnit(int baseQuantity, int conversionFactor) {
    return toDisplayQuantity(baseQuantity, conversionFactor);
  }

  static num convertDisplayQuantity(
    num displayQuantity,
    int oldFactor,
    int newFactor,
  ) {
    return displayQuantity *
        ensureSafeFactor(oldFactor) /
        ensureSafeFactor(newFactor);
  }

  static int? convertDisplayQuantityToInteger(
    int displayQuantity,
    int oldFactor,
    int newFactor,
  ) {
    final baseQuantity = displayQuantity * ensureSafeFactor(oldFactor);
    final safeNewFactor = ensureSafeFactor(newFactor);
    if (baseQuantity % safeNewFactor != 0) return null;
    return baseQuantity ~/ safeNewFactor;
  }

  static int convertUnitCost(int oldUnitCost, int oldFactor, int newFactor) {
    return (oldUnitCost *
            ensureSafeFactor(newFactor) /
            ensureSafeFactor(oldFactor))
        .round();
  }
}
