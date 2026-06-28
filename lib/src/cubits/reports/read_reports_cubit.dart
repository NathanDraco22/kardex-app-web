import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

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
