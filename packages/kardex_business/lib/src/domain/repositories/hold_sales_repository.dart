import '../../data/hold_sales_data_source.dart';
import '../../domain/models/hold_sale/hold_sale_model.dart';
import '../../domain/query_params/hold_sale_filter_params.dart';
import '../../domain/responses/list_responses.dart';

class HoldSalesRepository {
  final HoldSalesDataSource holdSalesDataSource;

  HoldSalesRepository(this.holdSalesDataSource);

  List<HoldSaleInDb> _holdSales = [];

  List<HoldSaleInDb> get holdSales => _holdSales;

  Future<HoldSaleInDb> createHoldSale(CreateHoldSale createHoldSale) async {
    final result = await holdSalesDataSource.createHoldSale(createHoldSale.toJson());
    final newHoldSale = HoldSaleInDb.fromJson(result);
    _holdSales = [newHoldSale, ..._holdSales];
    return newHoldSale;
  }

  Future<List<HoldSaleInDb>> getAllHoldSales([HoldSaleFilterParams? params]) async {
    final results = await holdSalesDataSource.getAllHoldSales(
      queryParams: params?.toMap(),
    );
    final response = ListResponse<HoldSaleInDb>.fromJson(
      results,
      HoldSaleInDb.fromJson,
    );

    _holdSales = response.data;
    return _holdSales;
  }

  Future<HoldSaleInDb?> getHoldSaleById(String holdSaleId) async {
    final result = await holdSalesDataSource.getHoldSaleById(holdSaleId);
    if (result == null) return null;
    return HoldSaleInDb.fromJson(result);
  }

  Future<HoldSaleInDb?> updateHoldSaleById(
    String holdSaleId,
    UpdateHoldSale holdSale,
  ) async {
    final result = await holdSalesDataSource.updateHoldSaleById(
      holdSaleId,
      holdSale.toJson(),
    );
    if (result == null) return null;

    final updatedHoldSale = HoldSaleInDb.fromJson(result);
    final index = _holdSales.indexWhere((u) => u.id == holdSaleId);
    if (index != -1) {
      _holdSales[index] = updatedHoldSale;
    }
    return updatedHoldSale;
  }

  Future<HoldSaleInDb?> deleteHoldSaleById(String holdSaleId) async {
    final result = await holdSalesDataSource.deleteHoldSaleById(holdSaleId);
    if (result == null) return null;

    _holdSales.removeWhere((u) => u.id == holdSaleId);
    return HoldSaleInDb.fromJson(result);
  }

  Future<void> deleteAllHoldSalesByBranch(String branchId) async {
    await holdSalesDataSource.deleteAllHoldSalesByBranch(branchId);
    _holdSales.removeWhere((s) => s.branchId == branchId);
  }
}
