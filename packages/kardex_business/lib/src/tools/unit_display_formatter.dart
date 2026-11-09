import 'package:kardex_business/src/tools/unit_conversion_tool.dart';

/// Resultado de presentación de una cantidad base en una unidad comercial.
class UnitDisplayValue {
  const UnitDisplayValue({
    required this.quantityText,
    required this.unitName,
    required this.usedStandardFallback,
  });

  final String quantityText;
  final String unitName;
  final bool usedStandardFallback;
}

/// Decide en qué unidad mostrar una cantidad base.
///
/// Reglas:
/// - La unidad estándar admite fracciones (Libra, Litro, Metro, Caja).
/// - Las unidades superiores solo se muestran enteras. Si la cantidad base no
///   es divisible por su factor, se muestra en la unidad estándar.
/// - Si faltan metadatos (documentos viejos), se conserva el fallback decimal
///   en la unidad seleccionada.
class UnitDisplayFormatter {
  static const int _maxDecimals = 6;

  static UnitDisplayValue formatUnitQuantity({
    required int baseQuantity,
    required int conversionFactor,
    String? selectedUnitName,
    String? standardUnitName,
    int? standardUnitFactor,
  }) {
    final safeFactor = UnitConversionTool.ensureSafeFactor(conversionFactor);
    final selectedName = _resolveUnitName(selectedUnitName, standardUnitName);
    final resolvedStandardFactor =
        standardUnitFactor != null && standardUnitFactor > 0
        ? standardUnitFactor
        : null;
    final standardName = _resolveUnitName(standardUnitName, selectedName);

    if (baseQuantity == 0) {
      return UnitDisplayValue(
        quantityText: '0',
        unitName: selectedName,
        usedStandardFallback: false,
      );
    }

    final isSuperiorUnit =
        resolvedStandardFactor != null && safeFactor > resolvedStandardFactor;

    if (isSuperiorUnit) {
      if (baseQuantity % safeFactor == 0) {
        return UnitDisplayValue(
          quantityText: _format(baseQuantity ~/ safeFactor),
          unitName: selectedName,
          usedStandardFallback: false,
        );
      }
      return UnitDisplayValue(
        quantityText: _format(baseQuantity / resolvedStandardFactor),
        unitName: standardName,
        usedStandardFallback: true,
      );
    }

    return UnitDisplayValue(
      quantityText: _format(baseQuantity / safeFactor),
      unitName: selectedName,
      usedStandardFallback: false,
    );
  }

  static String _format(num value) =>
      UnitConversionTool.formatQuantity(value, maxDecimals: _maxDecimals);

  static String _resolveUnitName(String? primary, String? fallback) {
    final primaryName = primary?.trim() ?? '';
    if (primaryName.isNotEmpty) return primaryName;
    final fallbackName = fallback?.trim() ?? '';
    return fallbackName;
  }
}
