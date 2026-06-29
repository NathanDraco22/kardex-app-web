import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/entry_history/entry_history_model.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';

class EntryHistoriesRepository {
  final EntryHistoriesDataSource entryHistoriesDataSource;

  EntryHistoriesRepository(this.entryHistoriesDataSource);

  Future<ListResponse<EntryHistoryInDb>> getEntryHistories({
    required String branchId,
    required int offset,
    int? limit,
    String? supplierId,
    int? startDate,
    int? endDate,
  }) async {
    final results = await entryHistoriesDataSource.getEntryHistories(
      branchId: branchId,
      offset: offset,
      limit: limit,
      supplierId: supplierId,
      startDate: startDate,
      endDate: endDate,
    );
    final response = ListResponse<EntryHistoryInDb>.fromJson(
      results,
      EntryHistoryInDb.fromJson,
    );
    return response;
  }

  Future<ListResponse<EntryHistoryInDb>> getEntryDocsByProductId(String productId) async {
    final results = await entryHistoriesDataSource.getEntryDocsByProductId(productId);
    final response = ListResponse<EntryHistoryInDb>.fromJson(
      results,
      EntryHistoryInDb.fromJson,
    );
    return response;
  }

  Future<EntryHistoryInDb> getEntryHistoryById(String entryHistoryId) async {
    final results = await entryHistoriesDataSource.getEntryHistoryById(entryHistoryId);
    final response = EntryHistoryInDb.fromJson(results);
    return response;
  }
}
