import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/inventory/inventory_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class InventoriesRepository {
  final InventoriesDataSource inventoriesDataSource;

  InventoriesRepository(this.inventoriesDataSource);

  Future<List<InventoryInDb>> getAllInventories() async {
    final results = await inventoriesDataSource.getAllInventories();

    final response = ListResponse<InventoryInDb>.fromJson(
      results,
      InventoryInDb.fromJson,
    );

    return response.data;
  }
}
