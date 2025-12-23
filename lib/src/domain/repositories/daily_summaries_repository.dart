import 'package:kardex_app_front/src/data/daily_summaries_data_source.dart';
import 'package:kardex_app_front/src/domain/models/daily_summary/daily_summary_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/daily_summary_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class DailySummariesRepository {
  final DailySummariesDataSource dataSource;

  DailySummariesRepository(this.dataSource);

  Future<List<DailySummaryInDb>> getAll(DailySummaryQueryParams params) async {
    final res = await dataSource.getAll(queryParams: params.toQueryParams());
    final response = ListResponse<DailySummaryInDb>.fromJson(res, DailySummaryInDb.fromJson);
    return response.data;
  }

  Future<DailySummaryInDb> getById(String id) async {
    final res = await dataSource.getById(id);
    return DailySummaryInDb.fromJson(res);
  }
}
