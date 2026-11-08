import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/models/inventory/inventory_model.dart';
import 'package:kardex_business/src/domain/models/inventory/reset_inventory_result.dart';
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

  Future<ResetInventoryResult> resetBranchInventory({
    required String branchId,
    required String branchNameConfirm,
    String? description,
    required UserInfo createdBy,
  }) async {
    final body = {
      'branchId': branchId,
      'branchNameConfirm': branchNameConfirm,
      'description':
          description ?? 'Reinicio de inventario a 0 (Zona de Peligro)',
      'createdBy': createdBy.toJson(),
    };

    final result = await inventoriesDataSource.resetBranchInventory(body);
    return ResetInventoryResult.fromJson(result);
  }
}
