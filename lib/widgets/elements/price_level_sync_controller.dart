import 'package:flutter/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

/// Controla la edición de varios niveles de precio en unidad base y,
/// opcionalmente, en una unidad extra seleccionada.
///
/// El precio base es la fuente de verdad. El precio por unidad extra se
/// calcula multiplicando el precio base por el factor de conversión. Si el
/// usuario edita el precio por unidad extra, se recalcula el precio base.
class PriceLevelSyncController {
  PriceLevelSyncController({
    this.levelCount = 4,
    required List<int> initialPrices,
    required List<ExtraUnit> extraUnits,
    int defaultUnitIndex = 0,
    int wholesaleUnitIndex = 0,
  }) {
    assert(levelCount > 0, "levelCount debe ser mayor a 0");

    _prices = List<int>.generate(
      levelCount,
      (index) => index < initialPrices.length ? initialPrices[index] : 0,
    );

    baseControllers = List<TextEditingController>.generate(
      levelCount,
      (index) => TextEditingController(text: centsToText(_prices[index])),
    );
    extraControllers = List<TextEditingController>.generate(
      levelCount,
      (_) => TextEditingController(),
    );
    baseFocusNodes = List<FocusNode>.generate(levelCount, (_) => FocusNode());
    extraFocusNodes = List<FocusNode>.generate(levelCount, (_) => FocusNode());

    _extraUnits = List<ExtraUnit>.from(extraUnits);
    selectedUnit = resolveInitialUnit(
      _extraUnits,
      defaultUnitIndex: defaultUnitIndex,
      wholesaleUnitIndex: wholesaleUnitIndex,
    );
    syncExtraControllers();
  }

  final int levelCount;

  late final List<TextEditingController> baseControllers;
  late final List<TextEditingController> extraControllers;
  late final List<FocusNode> baseFocusNodes;
  late final List<FocusNode> extraFocusNodes;

  late List<int> _prices;
  late List<ExtraUnit> _extraUnits;

  /// Unidad extra seleccionada para mostrar/editar precios equivalentes.
  ExtraUnit? selectedUnit;

  bool _isSyncing = false;

  /// Precios actuales en centavos, indexados desde 0.
  List<int> get prices => List<int>.unmodifiable(_prices);

  /// Unidades extra disponibles para el producto.
  List<ExtraUnit> get extraUnits => List<ExtraUnit>.unmodifiable(_extraUnits);

  /// Factor de conversión de la unidad seleccionada.
  int get factor => selectedUnit?.conversionFactor ?? 1;

  /// Indica si hay una unidad extra seleccionada y editable.
  bool get hasExtraUnit => selectedUnit != null && _extraUnits.isNotEmpty;

  /// Indica si la unidad seleccionada requiere conversión (factor > 1).
  bool get hasConversion => selectedUnit != null && factor > 1;

  /// Convierte un precio en centavos a un texto editable.
  static String centsToText(int cents) => (cents / 100).toStringAsFixed(2);

  /// Convierte el texto de un campo de precio a centavos.
  static int textToCents(String value) {
    final formattedValue = value.replaceAll(",", "");
    return ((double.tryParse(formattedValue) ?? 0) * 100).round();
  }

  /// Resuelve la unidad inicial usando la misma prioridad que el editor de
  /// precios: unidad por defecto, unidad de mayoreo y, por último, la primera.
  static ExtraUnit? resolveInitialUnit(
    List<ExtraUnit> units, {
    int defaultUnitIndex = 0,
    int wholesaleUnitIndex = 0,
  }) {
    if (units.isEmpty) return null;

    if (defaultUnitIndex > 0 && defaultUnitIndex - 1 < units.length) {
      return units[defaultUnitIndex - 1];
    }

    if (wholesaleUnitIndex > 0 && wholesaleUnitIndex - 1 < units.length) {
      return units[wholesaleUnitIndex - 1];
    }

    return units.first;
  }

  /// Actualiza el precio base de un nivel y recalcula su equivalente.
  void onBaseChanged(int level, String value) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final cents = textToCents(value);
      _prices[level] = cents;

      if (selectedUnit != null) {
        extraControllers[level].text = centsToText(cents * factor);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Actualiza el precio por unidad extra y recalcula el precio base.
  void onExtraChanged(int level, String value) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final extraCents = textToCents(value);
      final baseCents = factor > 0 ? (extraCents / factor).round() : extraCents;

      _prices[level] = baseCents;
      baseControllers[level].text = centsToText(baseCents);
    } finally {
      _isSyncing = false;
    }
  }

  /// Cambia la unidad extra seleccionada y refresca los campos equivalentes.
  void selectUnit(ExtraUnit? unit) {
    selectedUnit = unit;
    syncExtraControllers();
  }

  /// Refresca los campos de precio por unidad a partir de los precios base.
  void syncExtraControllers() {
    _isSyncing = true;
    try {
      for (var index = 0; index < levelCount; index++) {
        extraControllers[index].text = selectedUnit == null
            ? ''
            : centsToText(_prices[index] * factor);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Aplica el precio sugerido sobre el primer nivel de precio.
  void applySuggestedBasePrice(int baseCents) {
    _isSyncing = true;
    try {
      _prices[0] = baseCents;
      baseControllers[0].text = centsToText(baseCents);

      if (selectedUnit != null) {
        extraControllers[0].text = centsToText(baseCents * factor);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Reemplaza las unidades extra disponibles conservando la unidad
  /// seleccionada si sigue existiendo. Se usa después de editar el producto.
  void updateExtraUnits(
    List<ExtraUnit> units, {
    int defaultUnitIndex = 0,
    int wholesaleUnitIndex = 0,
  }) {
    final previousUnit = selectedUnit;

    _extraUnits = List<ExtraUnit>.from(units);

    selectedUnit = previousUnit == null
        ? null
        : _findEquivalentUnit(previousUnit);

    selectedUnit ??= resolveInitialUnit(
      _extraUnits,
      defaultUnitIndex: defaultUnitIndex,
      wholesaleUnitIndex: wholesaleUnitIndex,
    );

    syncExtraControllers();
  }

  ExtraUnit? _findEquivalentUnit(ExtraUnit target) {
    for (final unit in _extraUnits) {
      if (unit.name == target.name && unit.conversionFactor == target.conversionFactor) {
        return unit;
      }
    }
    return null;
  }

  void dispose() {
    for (final controller in baseControllers) {
      controller.dispose();
    }
    for (final controller in extraControllers) {
      controller.dispose();
    }
    for (final focusNode in baseFocusNodes) {
      focusNode.dispose();
    }
    for (final focusNode in extraFocusNodes) {
      focusNode.dispose();
    }
  }
}
