import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/reports/totals_result.dart';
import 'package:kardex_app_front/src/domain/query_params/totals_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_reports_state.dart';

class ReadReportsCubit extends Cubit<ReadReportsState> {
  ReadReportsCubit({
    required this.reportsRepository,
  }) : super(ReadReportsInitial()) {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
  }

  DateTime? startDate;
  DateTime? endDate;

  TotalsQueryParams params = TotalsQueryParams();

  final ReportsRepository reportsRepository;

  Future<void> loadReports(String branchId) async {
    emit(ReadReportsLoading());
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));

      params = TotalsQueryParams()
        ..branchId = branchId
        ..startDate = startDate
        ..endDate = topEndDate;

      final result = await reportsRepository.getTotalResultsByDateRange(params);

      emit(ReadReportsSuccess(result));
    } catch (e) {
      emit(ReadReportsError(e.toString()));
    }
  }

  void clearFilters(String branchId) {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
    loadReports(branchId);
  }
}
