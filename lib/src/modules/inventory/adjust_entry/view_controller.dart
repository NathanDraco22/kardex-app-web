import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustEntryViewController extends ChangeNotifier {
  AdjustEntryViewController() {
    tableController.addListener(_onTableChange);
  }

  final ProductTableController tableController = ProductTableController();

  DateTime? _docDate = DateTime.now();
  DateTime? get docDate => _docDate;
  set docDate(DateTime? value) {
    _docDate = value;
    notifyListeners();
  }

  String? _description;
  String? get description => _description;
  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  void _onTableChange() {
    notifyListeners();
  }

  bool get hasAllRequiredFields {
    return _docDate != null && tableController.rows.isNotEmpty;
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
    _description = null;
    _docDate = DateTime.now();
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

  CreateAdjustEntry? generateCreateAdjustEntry() {
    if (!hasAllRequiredFields) return null;

    final items = tableController.rows.map((e) {
      return EntryItem(
        productId: e.product.id,
        productName: e.product.name,
        cost: UnitConversionTool.toBaseCost(e.unitaryCost, e.conversionFactor),
        quantity: UnitConversionTool.toBaseQuantity(e.quantity, e.conversionFactor),
        conversionFactor: e.conversionFactor,
        expirationDate: e.expirationDate?.millisecondsSinceEpoch,
        brandName: e.product.brandName,
        code: e.product.code,
        unitName: UnitConversionTool.resolveUnitName(e.selectedUnitName, e.product.unitName),
      );
    }).toList();

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) throw Exception("User or branch not found");
    final currentUser = authState.session.user;

    return CreateAdjustEntry(
      branchId: getIt<AuthCubit>().currentBranchId,
      description: _description ?? "",
      items: items,
      createdBy: UserInfo(id: currentUser.id, name: currentUser.username),
    );
  }
}
