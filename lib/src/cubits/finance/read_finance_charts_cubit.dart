import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_finance_charts_state.dart';

class ReadFinanceChartsCubit extends Cubit<ReadFinanceChartsState> {
  final AdminPanelRepository adminPanelRepository;

  ReadFinanceChartsCubit(this.adminPanelRepository) : super(ReadFinanceChartsInitial());

  Future<void> getChartsCurrentBranch(String branchId) async {
    emit(ReadFinanceChartsLoading());
    try {
      final endDate = DateTimeTool.getTodayMidnight().millisecondsSinceEpoch;
      final res = await adminPanelRepository.getAdminChartsByBranch(
        branchId: branchId,
        endDate: endDate,
      );
      emit(ReadFinanceChartsSuccess(res));
    } catch (e) {
      emit(ReadFinanceChartsFailure(e.toString()));
    }
  }
}
