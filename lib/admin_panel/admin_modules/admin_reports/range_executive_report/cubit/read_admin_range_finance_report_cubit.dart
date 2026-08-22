import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_admin_range_finance_report_state.dart';

class ReadAdminRangeFinanceReportCubit extends Cubit<ReadAdminRangeFinanceReportState> {
  ReadAdminRangeFinanceReportCubit({
    required this.reportsRepository,
  }) : super(ReadAdminRangeFinanceReportInitial()) {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTimeTool.getTodayMidnight();
  }

  final ReportsRepository reportsRepository;

  DateTime? startDate;
  DateTime? endDate;

  Future<void> loadReport() async {
    if (startDate == null || endDate == null) return;
    emit(ReadAdminRangeFinanceReportLoading());
    try {
      // Ajustar fecha fin para incluir todo el día seleccionado
      final topEndDate = endDate!.add(const Duration(days: 1));

      final summary = await reportsRepository.getGeneralReport(
        startDate: startDate!,
        endDate: topEndDate,
      );

      emit(ReadAdminRangeFinanceReportSuccess(summary));
    } catch (e) {
      emit(ReadAdminRangeFinanceReportError(e.toString()));
    }
  }

  void clearFilters() {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTimeTool.getTodayMidnight();
    loadReport();
  }
}
