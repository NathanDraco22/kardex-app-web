import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';
import 'package:kardex_business/kardex_business.dart';

/// Fila editable del formulario de solicitud de ajuste.
///
/// El conteo se guarda en la unidad mostrada (admite decimales) y la
/// diferencia se calcula siempre en unidades base, que es lo que persiste el
/// backend.
class AdjustmentRequestRow {
  AdjustmentRequestRow({
    required this.product,
    required this.systemStock,
    required this.countedQuantity,
    this.selectedUnitIndex = 0,
    this.conversionFactor = 1,
    String? selectedUnitName,
    int? unitaryCost,
  }) : selectedUnitName = selectedUnitName ?? product.unitName,
       unitaryCost = unitaryCost ?? (product.account.averageCost * conversionFactor);

  final ProductInDbInBranch product;

  /// Existencia del sistema en unidades base al momento de editar la fila.
  ///
  /// Al guardar, el backend vuelve a tomar la foto del ProductAccount, por eso
  /// la edición usa la existencia actual y no la que tenía la solicitud original.
  final int systemStock;

  double countedQuantity;
  int selectedUnitIndex;
  int conversionFactor;
  String selectedUnitName;

  /// Costo por unidad mostrada, en centavos.
  int unitaryCost;

  String get unitName => UnitConversionTool.resolveUnitName(selectedUnitName, product.unitName);

  int get safeFactor => UnitConversionTool.ensureSafeFactor(conversionFactor);

  bool get hasExactBaseQuantity {
    final rawBase = countedQuantity * safeFactor;
    return (rawBase - rawBase.roundToDouble()).abs() <= 1e-6;
  }

  int get countedBaseQuantity => (countedQuantity * safeFactor).round();

  int get difference => countedBaseQuantity - systemStock;

  int get averageBaseCost => product.account.averageCost;

  int get baseUnitCost => UnitConversionTool.toBaseCost(unitaryCost, conversionFactor);

  /// Para faltantes el backend recalcula el costo de salida, por eso se
  /// muestra el costo promedio como referencia.
  int get effectiveBaseCost => difference > 0 ? baseUnitCost : averageBaseCost;

  int get subtotal => difference.abs() * effectiveBaseCost;

  num get systemStockInDisplayUnit => UnitConversionTool.toDisplayQuantity(systemStock, conversionFactor);

  num get differenceInDisplayUnit => UnitConversionTool.toDisplayQuantity(difference, conversionFactor);

  bool get hasSurplus => difference > 0;

  bool get hasShortage => difference < 0;
}

class AdjustmentRequestViewController extends ChangeNotifier {
  final List<AdjustmentRequestRow> _rows = [];
  String _description = '';
  DateTime? _docDate = DateTime.now();
  int _sessionId = 0;

  DateTime? get docDate => _docDate;
  set docDate(DateTime? value) {
    _docDate = value;
    notifyListeners();
  }

  String get description => _description;
  set description(String value) {
    if (_description == value) return;
    _description = value;
    notifyListeners();
  }

  List<AdjustmentRequestRow> get rows => List.unmodifiable(_rows);

  int get productCount => _rows.length;

  int get totalSurplus => _rows.where((row) => row.hasSurplus).fold<int>(0, (sum, row) => sum + row.subtotal);

  int get totalShortage => _rows.where((row) => row.hasShortage).fold<int>(0, (sum, row) => sum + row.subtotal);

  int get netTotal => totalSurplus - totalShortage;

  bool get hasItems => _rows.isNotEmpty;

  bool get hasNonZeroDifference => _rows.any((row) => row.difference != 0);

  bool get hasNegativeCountedQuantity => _rows.any((row) => row.countedQuantity < 0);

  bool get hasInvalidBaseQuantity => _rows.any((row) => !row.hasExactBaseQuantity);

  bool get canSave =>
      hasItems &&
      hasNonZeroDifference &&
      !hasNegativeCountedQuantity &&
      !hasInvalidBaseQuantity;

  String? get validationMessage {
    if (!hasItems) return 'Agrega al menos un producto a la solicitud.';
    if (hasNegativeCountedQuantity) return 'El conteo real no puede ser negativo.';
    if (hasInvalidBaseQuantity) {
      return 'El conteo debe equivaler a una cantidad entera en la unidad base.';
    }
    if (!hasNonZeroDifference) return 'Registra al menos una diferencia distinta de cero.';
    return null;
  }

  Key get formKey => ValueKey(_sessionId);

  bool containsProduct(String productId) => _rows.any((row) => row.product.id == productId);

  bool addRow(AdjustmentRequestRow row) {
    if (containsProduct(row.product.id)) return false;
    _rows.add(row);
    notifyListeners();
    return true;
  }

  void removeRow(AdjustmentRequestRow row) {
    if (!_rows.remove(row)) return;
    notifyListeners();
  }

  void notifyRowChanged() => notifyListeners();

  void changeUnit(AdjustmentRequestRow row, UnitPickerResult unit) {
    final baseCount = row.countedBaseQuantity;
    final factor = UnitConversionTool.ensureSafeFactor(unit.conversionFactor);

    row.selectedUnitIndex = unit.unitIndex;
    row.conversionFactor = factor;
    row.selectedUnitName = unit.unitName;
    row.countedQuantity = UnitConversionTool.toDisplayQuantity(baseCount, factor).toDouble();
    row.unitaryCost = row.product.account.averageCost * factor;
    notifyListeners();
  }

  /// Carga una solicitud existente en el formulario.
  ///
  /// Devuelve `false` si algún producto de la solicitud ya no existe en la
  /// sucursal, para que la pantalla bloquee el guardado en lugar de eliminar
  /// filas silenciosamente.
  bool prefill({
    required AdjustmentRequestInDb request,
    required List<ProductInDbInBranch> products,
  }) {
    _rows.clear();
    _description = request.description;
    _docDate = DateTime.fromMillisecondsSinceEpoch(request.createdAt);

    final productsById = {for (final product in products) product.id: product};
    var allProductsFound = true;

    for (final item in request.items) {
      final product = productsById[item.productId];
      if (product == null) {
        allProductsFound = false;
        continue;
      }

      final factor = UnitConversionTool.ensureSafeFactor(item.conversionFactor);
      final unitIndex = _resolveUnitIndex(product, item.unitName, factor);
      final selectedUnitName = item.unitName ?? product.unitName;
      final displayCost = item.difference > 0 ? item.cost * factor : product.account.averageCost * factor;

      _rows.add(
        AdjustmentRequestRow(
          product: product,
          systemStock: product.account.currentStock,
          countedQuantity: item.countedQuantity / factor,
          selectedUnitIndex: unitIndex,
          conversionFactor: factor,
          selectedUnitName: selectedUnitName,
          unitaryCost: displayCost,
        ),
      );
    }

    _sessionId++;
    notifyListeners();
    return allProductsFound;
  }

  int _resolveUnitIndex(ProductInDbInBranch product, String? unitName, int factor) {
    if (unitName == null || unitName == product.unitName) return 0;

    for (var index = 0; index < product.extraUnits.length; index++) {
      final extra = product.extraUnits[index];
      if (extra.name == unitName && extra.conversionFactor == factor) {
        return index + 1;
      }
    }

    return 0;
  }

  CreateAdjustmentRequest? generateCreateAdjustmentRequest() {
    if (!canSave) return null;

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return null;

    final user = authState.session.user;
    return CreateAdjustmentRequest(
      branchId: authState.branch.id,
      description: _description.trim(),
      items: _rows.map(_toItem).toList(growable: false),
      createdBy: UserInfo(id: user.id, name: user.username),
    );
  }

  UpdateAdjustmentRequest? generateUpdateAdjustmentRequest() {
    if (!canSave) return null;
    return UpdateAdjustmentRequest(
      description: _description.trim(),
      items: _rows.map(_toItem).toList(growable: false),
    );
  }

  AdjustmentRequestItem _toItem(AdjustmentRequestRow row) {
    return AdjustmentRequestItem(
      productId: row.product.id,
      productName: row.product.name,
      code: row.product.code,
      brandName: row.product.brandName,
      unitName: row.unitName,
      standardUnitName: row.product.defaultUnitName,
      standardUnitFactor: row.product.defaultUnitFactor,
      conversionFactor: row.conversionFactor,
      systemStock: row.systemStock,
      countedQuantity: row.countedBaseQuantity,
      difference: row.difference,
      cost: row.effectiveBaseCost,
      subtotal: row.subtotal,
    );
  }

  void clear() {
    _rows.clear();
    _description = '';
    _docDate = DateTime.now();
    _sessionId++;
    notifyListeners();
  }
}
