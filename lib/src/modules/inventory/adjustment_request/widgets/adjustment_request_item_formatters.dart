import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

String formatAdjustmentDisplayQuantity(int baseQuantity, int conversionFactor) {
  final factor = UnitConversionTool.ensureSafeFactor(conversionFactor);
  return UnitConversionTool.formatQuantity(baseQuantity / factor);
}

String formatAdjustmentSignedQuantity(int difference, int conversionFactor) {
  final factor = UnitConversionTool.ensureSafeFactor(conversionFactor);
  final display = difference / factor;
  if (display == 0) return '0';
  final formatted = UnitConversionTool.formatQuantity(display.abs());
  return display > 0 ? '+$formatted' : '-$formatted';
}

String formatAdjustmentUnitCost(int baseCost, int conversionFactor) {
  final factor = UnitConversionTool.ensureSafeFactor(conversionFactor);
  return NumberFormatter.convertToMoneyLike(baseCost * factor);
}

Color adjustmentDifferenceColor(int difference) {
  if (difference > 0) return AppThemeTokens.success;
  if (difference < 0) return AppThemeTokens.danger;
  return AppThemeTokens.neutral;
}

IconData adjustmentDifferenceIcon(int difference) {
  if (difference > 0) return Icons.arrow_upward_rounded;
  if (difference < 0) return Icons.arrow_downward_rounded;
  return Icons.remove_rounded;
}
