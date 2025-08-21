import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/entry_history/entry_history_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class EntryHistoriesRepository {
  final EntryHistoriesDataSource entryHistoriesDataSource;

  EntryHistoriesRepository(this.entryHistoriesDataSource);

  Future<ListResponse<EntryHistoryInDb>> getEntryHistories({
    required int offset,
    int? limit,
    String? supplierId,
    required String branchId,
  }) async {
    final results = await entryHistoriesDataSource.getEntryHistories(
      offset: offset,
      limit: limit,
      supplierId: supplierId,
      branchId: branchId,
    );
    final response = ListResponse<EntryHistoryInDb>.fromJson(
      results,
      EntryHistoryInDb.fromJson,
    );
    return response;
  }
}
