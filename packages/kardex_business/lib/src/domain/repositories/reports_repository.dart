import 'package:kardex_business/src/data/reports_data_source.dart';
import 'package:kardex_business/src/domain/models/executive_summary/executive_summary_in_db.dart';
import 'package:kardex_business/src/domain/query_params/totals_query_params.dart';
import 'package:kardex_business/src/domain/models/reports/totals_result.dart';

class ReportsRepository {
  final ReportsDataSource reportsDataSource;

  ReportsRepository(this.reportsDataSource);

  Future<TotalsResult> getTotalResultsByDateRange(TotalsQueryParams params) async {
    final result = await reportsDataSource.getTotalResultsByDateRange(params.toMap());
    return TotalsResult.fromJson(result);
  }

  Future<ExecutiveSummaryInDb> getGeneralReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final params = {
      'startDate': startDate.millisecondsSinceEpoch.toString(),
      'endDate': endDate.millisecondsSinceEpoch.toString(),
    };
    final result = await reportsDataSource.getGeneralReport(params);
    return ExecutiveSummaryInDb.fromJson(result);
  }
}
