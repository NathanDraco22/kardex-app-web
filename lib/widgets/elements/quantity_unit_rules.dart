import 'package:kardex_business/kardex_business.dart';

/// Reglas compartidas de cantidad por unidad comercial.
///
/// - La unidad base (índice 0) siempre es entera.
/// - La unidad estándar (índice hasta `defaultUnitIndex`) permite fracciones.
/// - Las unidades superiores al índice por defecto solo admiten enteros.
class QuantityUnitRules {
  const QuantityUnitRules._();

  static const double _tolerance = 1e-6;

  static bool isSuperiorUnit({
    required int selectedUnitIndex,
    required int defaultUnitIndex,
  }) {
    return selectedUnitIndex > defaultUnitIndex;
  }

  static bool allowsDecimals({
    required int selectedUnitIndex,
    required int defaultUnitIndex,
  }) {
    return selectedUnitIndex > 0 &&
        !isSuperiorUnit(
          selectedUnitIndex: selectedUnitIndex,
          defaultUnitIndex: defaultUnitIndex,
        );
  }

  /// Convierte la cantidad mostrada al cambiar de unidad.
  ///
  /// Devuelve `null` cuando la conversión no puede representarse exactamente:
  /// - la cantidad anterior no equivale a una cantidad base entera;
  /// - la nueva unidad es superior y la cantidad base no es múltiplo de su
  ///   factor (las unidades superiores solo aceptan enteros);
  /// - [requireIntegerDisplay] y el resultado tiene fracción.
  ///
  /// El llamador debe reiniciar la cantidad a 0. Puede informar la equivalencia
  /// si el flujo lo requiere.
  static double? convertOnUnitChange({
    required num displayQuantity,
    required int oldFactor,
    required int newFactor,
    required bool newUnitIsSuperior,
    bool requireIntegerDisplay = false,
  }) {
    final oldSafeFactor = UnitConversionTool.ensureSafeFactor(oldFactor);
    final newSafeFactor = UnitConversionTool.ensureSafeFactor(newFactor);

    final baseQuantity = displayQuantity.toDouble() * oldSafeFactor;
    final roundedBase = baseQuantity.roundToDouble();
    if ((baseQuantity - roundedBase).abs() > _tolerance) return null;

    final baseInt = roundedBase.toInt();
    if (newUnitIsSuperior) {
      if (baseInt % newSafeFactor != 0) return null;
      return (baseInt ~/ newSafeFactor).toDouble();
    }

    final displayResult = baseInt / newSafeFactor;
    if (requireIntegerDisplay && (displayResult - displayResult.roundToDouble()).abs() > _tolerance) {
      return null;
    }
    return displayResult;
  }
}
