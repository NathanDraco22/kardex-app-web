import 'package:kardex_app_front/src/data/executive_summaries_data_source.dart';
import 'package:kardex_app_front/src/domain/models/executive_summary/executive_summary_in_db.dart';
import 'package:kardex_app_front/src/domain/query_params/daily_summary_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExecutiveSummariesRepository {
  final ExecutiveSummariesDataSource dataSource;

  ExecutiveSummariesRepository(this.dataSource);

  Future<List<ExecutiveSummaryInDb>> getAll(DailySummaryQueryParams params) async {
    final res = await dataSource.getAll(queryParams: params.toQueryParams());
    final response = ListResponse<ExecutiveSummaryInDb>.fromJson(res, ExecutiveSummaryInDb.fromJson);
    return response.data;
  }

  Future<ExecutiveSummaryInDb> getById(String id) async {
    final res = await dataSource.getById(id);
    return ExecutiveSummaryInDb.fromJson(res);
  }
}
