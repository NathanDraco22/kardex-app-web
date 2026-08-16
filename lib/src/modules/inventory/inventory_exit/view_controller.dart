import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';
import 'package:kardex_business/kardex_business.dart';

class InventoryExitViewController extends ChangeNotifier {
  InventoryExitViewController() {
    tableController.addListener(_onTableChange);
  }

  final ProductTableController tableController = ProductTableController();

  ClientInDb? _selectedClient;
  ClientInDb? get selectedClient => _selectedClient;
  set selectedClient(ClientInDb? value) {
    _selectedClient = value;
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
    return _selectedClient != null &&
        (_docNumber?.isNotEmpty ?? false) &&
        _docDate != null &&
        tableController.rows.isNotEmpty;
  }

  bool get hasProductWithZeroValue {
    return tableController.rows.any((r) => r.quantity == 0);
  }

  int get productCount => tableController.rows.length;

  int get total => tableController.total;

  int _sessionId = 0;
  Key get formKey => ValueKey(_sessionId);

  void refresh() => notifyListeners();

  void clear() {
    _selectedClient = null;
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

  CreateExitDoc? generateCreateExitDoc() {
    if (!hasAllRequiredFields) return null;

    final items = tableController.rows.map((e) {
      return ExitItem(
        productId: e.product.id,
        productName: e.product.name,
        quantity: UnitConversionTool.toBaseQuantity(e.quantity, e.conversionFactor) * -1,
        brandName: e.product.brandName,
        unitName: UnitConversionTool.resolveUnitName(e.selectedUnitName, e.product.unitName),
        code: e.product.code,
        conversionFactor: e.conversionFactor,
      );
    }).toList();

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) throw Exception("User or branch not found");
    final currentUser = authState.session.user;

    return CreateExitDoc(
      clientId: _selectedClient!.id,
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
