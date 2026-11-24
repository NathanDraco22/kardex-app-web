import 'dart:math';

class UnitConversionTool {
  static int ensureSafeFactor(int factor) => max(factor, 1);

  static double minimumStep(int conversionFactor) =>
      1 / ensureSafeFactor(conversionFactor);

  static int toBaseQuantity(num displayQuantity, int conversionFactor) {
    return (displayQuantity * ensureSafeFactor(conversionFactor)).round();
  }

  static int _divRoundHalfUp(int numerator, int denominator) {
    final safeDen = ensureSafeFactor(denominator);
    if (safeDen == 1) return numerator;
    if (numerator >= 0) {
      return (numerator + (safeDen ~/ 2)) ~/ safeDen;
    }
    return -((numerator.abs() + (safeDen ~/ 2)) ~/ safeDen);
  }

  static int toStoredPriceOrCost(
    int displayCents,
    int conversionFactor, {
    int priceUnitFactor = 1,
  }) {
    final safeFactor = ensureSafeFactor(conversionFactor);
    final safePriceFactor = ensureSafeFactor(priceUnitFactor);
    if (safeFactor == safePriceFactor) return displayCents;
    return _divRoundHalfUp(displayCents * safePriceFactor, safeFactor);
  }

  static int toDisplayPriceOrCost(
    int storedCents,
    int conversionFactor, {
    int priceUnitFactor = 1,
  }) {
    final safeFactor = ensureSafeFactor(conversionFactor);
    final safePriceFactor = ensureSafeFactor(priceUnitFactor);
    if (safeFactor == safePriceFactor) return storedCents;
    return _divRoundHalfUp(storedCents * safeFactor, safePriceFactor);
  }

  static int calculateLineTotal(
    int storedCents,
    int baseQuantity, {
    int priceUnitFactor = 1,
  }) {
    final safePriceFactor = ensureSafeFactor(priceUnitFactor);
    if (safePriceFactor == 1) return storedCents * baseQuantity;
    return _divRoundHalfUp(storedCents * baseQuantity, safePriceFactor);
  }

  static int toBaseCost(
    int unitaryCost,
    int conversionFactor, {
    int priceUnitFactor = 1,
  }) {
    return toStoredPriceOrCost(
      unitaryCost,
      conversionFactor,
      priceUnitFactor: priceUnitFactor,
    );
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
