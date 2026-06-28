import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_admin_panel_state.dart';

class ReadAdminPanelCubit extends Cubit<ReadAdminPanelState> {
  final AdminPanelRepository adminPanelRepository;

  ReadAdminPanelCubit(this.adminPanelRepository) : super(ReadAdminPanelInitial());

  Future<void> getCharts() async {
    emit(ReadAdminPanelLoading());
    try {
      final endDate = DateTimeTool.getTodayMidnight().millisecondsSinceEpoch;
      final res = await adminPanelRepository.getAdminCharts(endDate: endDate);
      emit(ReadAdminPanelSuccess(res));
    } catch (e) {
      emit(ReadAdminPanelFailure(e.toString()));
    }
  }
}
