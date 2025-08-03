import 'package:kardex_app_front/src/data/supplier_data_source.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class SuppliersRepository {
  final SuppliersDataSource suppliersDataSource;

  SuppliersRepository(this.suppliersDataSource);

  List<SupplierInDb> _suppliers = [];

  List<SupplierInDb> get suppliers => _suppliers;

  Future<SupplierInDb> createSupplier(CreateSupplier createSupplier) async {
    final result = await suppliersDataSource.createSupplier(createSupplier.toJson());
    final newSupplier = SupplierInDb.fromJson(result);
    _suppliers = [newSupplier, ..._suppliers];
    return newSupplier;
  }

  Future<List<SupplierInDb>> getAllSuppliers() async {
    final results = await suppliersDataSource.getAllSuppliers();
    final models = ListResponse<SupplierInDb>.fromJson(
      results,
      SupplierInDb.fromJson,
    );

    _suppliers = models.data;
    _suppliers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return _suppliers;
  }

  Future<SupplierInDb?> getSupplierById(String supplierId) async {
    final result = await suppliersDataSource.getSupplierById(supplierId);

    if (result == null) {
      return null;
    }

    return SupplierInDb.fromJson(result);
  }

  Future<List<SupplierInDb>> searchSupplierByKeyword(String keyword) async {
    final result = await suppliersDataSource.searchSupplierByKeyword(keyword);
    final suppliers = ListResponse<SupplierInDb>.fromJson(result, SupplierInDb.fromJson).data;
    return suppliers;
  }

  Future<SupplierInDb?> updateSupplierById(
    String supplierId,
    UpdateSupplier supplier,
  ) async {
    final result = await suppliersDataSource.updateSupplierById(
      supplierId,
      supplier.toJson(),
    );

    if (result == null) {
      return null;
    }

    final updatedSupplier = SupplierInDb.fromJson(result);
    final index = _suppliers.indexWhere((s) => s.id == supplierId);
    if (index != -1) {
      _suppliers[index] = updatedSupplier;
    }
    return updatedSupplier;
  }

  Future<SupplierInDb?> deleteSupplierById(String supplierId) async {
    final result = await suppliersDataSource.deleteSupplierById(supplierId);

    if (result == null) {
      return null;
    }

    final deletedSupplier = SupplierInDb.fromJson(result);
    _suppliers.removeWhere((s) => s.id == supplierId);
    return deletedSupplier;
  }
}
