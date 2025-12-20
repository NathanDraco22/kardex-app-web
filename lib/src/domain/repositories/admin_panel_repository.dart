import 'package:kardex_app_front/src/data/admin_panel_data_source.dart';
import 'package:kardex_app_front/src/domain/responses/admin_charts_responses.dart';

class AdminPanelRepository {
  final AdminPanelDataSource adminPanelDataSource;

  AdminPanelRepository(this.adminPanelDataSource);

  Future<AdminChartsResponses> getAdminCharts({required int endDate}) async {
    final res = await adminPanelDataSource.getAdminCharts(endDate: endDate);
    return AdminChartsResponses.fromJson(res);
  }

  Future<AdminChartsResponses> getAdminChartsByBranch({
    required String branchId,
    required int endDate,
  }) async {
    final res = await adminPanelDataSource.getAdminChartsByBranch(
      branchId: branchId,
      endDate: endDate,
    );
    return AdminChartsResponses.fromJson(res);
  }
}
