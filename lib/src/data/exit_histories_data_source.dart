import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ExitHistoriesDataSource with HttpService {
  ExitHistoriesDataSource._();
  static final ExitHistoriesDataSource instance = ExitHistoriesDataSource._();
  factory ExitHistoriesDataSource() {
    return instance;
  }

  final _endpoint = "/exit-histories";

  Future<Map<String, dynamic>> getExitHistories({
    required int offset,
    String? clientId,
    int? startDate,
    int? endDate,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "offset": offset.toString(),
        "limit": 50.toString(),
        "clientId": ?clientId,
        "startDate": ?startDate?.toString(),
        "endDate": ?endDate?.toString(),
        "branchId": currentBranch,
      },
    );
    final res = await getQuery(uri);
    return res;
  }
}
