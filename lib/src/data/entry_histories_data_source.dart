import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class EntryHistoriesDataSource with HttpService {
  EntryHistoriesDataSource._();
  static final EntryHistoriesDataSource instance = EntryHistoriesDataSource._();
  factory EntryHistoriesDataSource() {
    return instance;
  }

  final _endpoint = "/entry-histories";

  Future<Map<String, dynamic>> getEntryHistories({
    required int offset,
    int? limit,
    String? supplierId,
    String? startDate,
    String? endDate,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "offset": offset.toString(),
        "limit": 50.toString(),
        "supplierId": ?supplierId,
        "startDate": ?startDate,
        "endDate": ?endDate,
        "branchId": currentBranch,
      },
    );
    final res = await getQuery(uri);
    return res;
  }
}
