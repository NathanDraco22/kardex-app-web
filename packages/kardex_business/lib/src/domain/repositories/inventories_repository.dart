import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/inventory/inventory_model.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';

class InventoriesRepository {
  final InventoriesDataSource inventoriesDataSource;

  InventoriesRepository(this.inventoriesDataSource);

  Future<List<InventoryInDb>> getAllInventories(String branchId) async {
    final results = await inventoriesDataSource.getAllInventories(branchId);

    final response = ListResponse<InventoryInDb>.fromJson(
      results,
      InventoryInDb.fromJson,
    );

    return response.data;
  }
}
