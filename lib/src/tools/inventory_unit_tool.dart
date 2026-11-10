import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/elements/quantity_unit_rules.dart';

/// Una unidad seleccionable para agregar o restar stock.
///
/// El índice 0 es la unidad base; los siguientes corresponden a las unidades
/// extra del producto (1..n).
class InventoryUnitOption {
  const InventoryUnitOption({
    required this.index,
    required this.name,
    required this.factor,
  });

  final int index;
  final String name;
  final int factor;

  bool get isBase => index == 0;
}

/// Utilidades de conversión entre la unidad de venta seleccionada y la unidad
/// base del producto.
class InventoryUnitTool {
  const InventoryUnitTool._();

  static List<InventoryUnitOption> buildOptions({
    required String baseUnitName,
    required List<ExtraUnit> extraUnits,
  }) {
    return [
      InventoryUnitOption(index: 0, name: baseUnitName, factor: 1),
      for (var index = 0; index < extraUnits.length; index++)
        InventoryUnitOption(
          index: index + 1,
          name: extraUnits[index].name,
          factor: UnitConversionTool.ensureSafeFactor(extraUnits[index].conversionFactor),
        ),
    ];
  }

  /// Resuelve la unidad de venta por defecto (`defaultUnitIndex`).
  static InventoryUnitOption resolveDefault({
    required List<InventoryUnitOption> options,
    required int defaultUnitIndex,
  }) {
    if (defaultUnitIndex >= 0 && defaultUnitIndex < options.length) {
      return options[defaultUnitIndex];
    }
    return options.first;
  }

  /// Indica si la unidad permite cantidades fraccionarias según las reglas de
  /// unidades comerciales de la app.
  static bool allowsDecimals({
    required InventoryUnitOption option,
    required int defaultUnitIndex,
  }) {
    return QuantityUnitRules.allowsDecimals(
      selectedUnitIndex: option.index,
      defaultUnitIndex: defaultUnitIndex,
    );
  }

  static int toBaseQuantity(num displayQuantity, int factor) {
    return (displayQuantity * UnitConversionTool.ensureSafeFactor(factor)).round();
  }

  static int toBaseCost(int displayCostCents, int factor) {
    return UnitConversionTool.toBaseCost(displayCostCents, factor);
  }

  static int toDisplayCost(int baseCostCents, int factor) {
    return baseCostCents * UnitConversionTool.ensureSafeFactor(factor);
  }

  /// Convierte una cantidad mostrada entre dos unidades conservando la
  /// cantidad base. Devuelve `null` si no puede representarse exactamente.
  static double? convertDisplayQuantity({
    required num displayQuantity,
    required int oldFactor,
    required int newFactor,
    required int newUnitIndex,
    required int defaultUnitIndex,
  }) {
    return QuantityUnitRules.convertOnUnitChange(
      displayQuantity: displayQuantity,
      oldFactor: oldFactor,
      newFactor: newFactor,
      newUnitIsSuperior: QuantityUnitRules.isSuperiorUnit(
        selectedUnitIndex: newUnitIndex,
        defaultUnitIndex: defaultUnitIndex,
      ),
      requireIntegerDisplay: false,
    );
  }

  static int convertDisplayCost({
    required int displayCostCents,
    required int oldFactor,
    required int newFactor,
  }) {
    return UnitConversionTool.convertUnitCost(displayCostCents, oldFactor, newFactor);
  }

  static String formatQuantity(num quantity) {
    return UnitConversionTool.formatQuantity(quantity, maxDecimals: 6);
  }

  static String formatBaseStock(int baseStock, int factor) {
    return formatQuantity(baseStock / UnitConversionTool.ensureSafeFactor(factor));
  }

  static String formatMoney(int cents) {
    return (cents / 100).toStringAsFixed(2);
  }
}
