import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/admin_panel_repository.dart';
import 'package:kardex_app_front/src/domain/responses/admin_charts_responses.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_finance_charts_state.dart';

class ReadFinanceChartsCubit extends Cubit<ReadFinanceChartsState> {
  final AdminPanelRepository adminPanelRepository;

  ReadFinanceChartsCubit(this.adminPanelRepository) : super(ReadFinanceChartsInitial());

  Future<void> getChartsCurrentBranch() async {
    emit(ReadFinanceChartsLoading());
    try {
      final endDate = DateTimeTool.getTodayMidnight().millisecondsSinceEpoch;
      final res = await adminPanelRepository.getAdminChartsByBranch(
        branchId: BranchesTool.getCurrentBranchId(),
        endDate: endDate,
      );
      emit(ReadFinanceChartsSuccess(res));
    } catch (e) {
      emit(ReadFinanceChartsFailure(e.toString()));
    }
  }
}
