import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/exit_history/exit_history_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExitHistoriesRepository {
  final ExitHistoriesDataSource exitHistoriesDataSource;

  ExitHistoriesRepository(this.exitHistoriesDataSource);

  Future<ListResponse<ExitHistoryInDb>> getExitHistories({
    required int offset,
    int? limit,
    String? clientId,
    required String branchId,
  }) async {
    final results = await exitHistoriesDataSource.getExitHistories(
      offset: offset,
      limit: limit,
      clientId: clientId,
      branchId: branchId,
    );
    final response = ListResponse<ExitHistoryInDb>.fromJson(
      results,
      ExitHistoryInDb.fromJson,
    );
    return response;
  }
}
