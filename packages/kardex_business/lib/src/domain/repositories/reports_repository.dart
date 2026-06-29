import 'package:kardex_business/src/data/reports_data_source.dart';
import 'package:kardex_business/src/domain/query_params/totals_query_params.dart';
import 'package:kardex_business/src/domain/models/reports/totals_result.dart';

class ReportsRepository {
  final ReportsDataSource reportsDataSource;

  ReportsRepository(this.reportsDataSource);

  Future<TotalsResult> getTotalResultsByDateRange(TotalsQueryParams params) async {
    final result = await reportsDataSource.getTotalResultsByDateRange(params.toMap());
    return TotalsResult.fromJson(result);
  }
}
