import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';
import 'package:kardex_business/kardex_business.dart';

class InventoryEntryViewController extends ChangeNotifier {
  InventoryEntryViewController() {
    tableController.addListener(_onTableChange);
  }

  final ProductTableController tableController = ProductTableController();

  SupplierInDb? _selectedSupplier;
  SupplierInDb? get selectedSupplier => _selectedSupplier;
  set selectedSupplier(SupplierInDb? value) {
    _selectedSupplier = value;
    notifyListeners();
  }

  String? _docNumber;
  String? get docNumber => _docNumber;
  set docNumber(String? value) {
    _docNumber = value;
    notifyListeners();
  }

  DateTime? _docDate;
  DateTime? get docDate => _docDate;
  set docDate(DateTime? value) {
    _docDate = value;
    notifyListeners();
  }

  String? _observations;
  String? get observations => _observations;
  set observations(String? value) {
    _observations = value;
    notifyListeners();
  }

  void _onTableChange() {
    notifyListeners();
  }

  bool get hasAllRequiredFields {
    return _selectedSupplier != null &&
        (_docNumber?.isNotEmpty ?? false) &&
        _docDate != null &&
        tableController.rows.isNotEmpty;
  }

  bool get hasProductWithZeroValue {
    return tableController.rows.any((r) => r.quantity == 0 || r.unitaryCost == 0);
  }

  int get productCount => tableController.rows.length;

  int get total => tableController.total;

  int _sessionId = 0;
  Key get formKey => ValueKey(_sessionId);

  void refresh() => notifyListeners();

  void clear() {
    _selectedSupplier = null;
    _docNumber = null;
    _docDate = null;
    _observations = null;
    tableController.clear();
    _sessionId++;
    notifyListeners();
  }

  @override
  void dispose() {
    tableController.removeListener(_onTableChange);
    tableController.dispose();
    super.dispose();
  }

  CreateEntryDoc? generateCreateEntryDoc() {
    if (!hasAllRequiredFields) return null;

    final items = tableController.rows.map((e) {
      return EntryItem(
        productId: e.product.id,
        productName: e.product.name,
        quantity: UnitConversionTool.toBaseQuantity(e.quantity, e.conversionFactor),
        cost: UnitConversionTool.toBaseCost(e.unitaryCost, e.conversionFactor),
        conversionFactor: e.conversionFactor,
        code: e.product.code,
        brandName: e.product.brandName,
        unitName: UnitConversionTool.resolveUnitName(e.selectedUnitName, e.product.unitName),
        expirationDate: e.expirationDate?.millisecondsSinceEpoch,
      );
    }).toList();

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) throw Exception("User or branch not found");
    final currentUser = authState.session.user;

    return CreateEntryDoc(
      supplierId: _selectedSupplier!.id,
      docNumber: _docNumber!,
      docDate: _docDate!,
      branchId: getIt<AuthCubit>().currentBranchId,
      items: items,
      createdBy: UserInfo(
        id: currentUser.id,
        name: currentUser.username,
      ),
    );
  }
}
