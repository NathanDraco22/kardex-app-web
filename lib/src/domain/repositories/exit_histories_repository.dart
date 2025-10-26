import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/exit_history/exit_history_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExitHistoriesRepository {
  final ExitHistoriesDataSource exitHistoriesDataSource;

  ExitHistoriesRepository(this.exitHistoriesDataSource);

  Future<ListResponse<ExitHistoryInDb>> getExitHistories({
    required int offset,
    String? clientId,
    int? startDate,
    int? endDate,
  }) async {
    final results = await exitHistoriesDataSource.getExitHistories(
      offset: offset,
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
    );
    final response = ListResponse<ExitHistoryInDb>.fromJson(
      results,
      ExitHistoryInDb.fromJson,
    );
    return response;
  }

  Future<ExitHistoryInDb> getExitHistoryById(String exitHistoryId) async {
    final results = await exitHistoriesDataSource.getExitHistoryById(exitHistoryId);
    final response = ExitHistoryInDb.fromJson(results);
    return response;
  }
}
