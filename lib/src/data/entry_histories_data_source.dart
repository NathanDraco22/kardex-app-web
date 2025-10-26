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
    int? startDate,
    int? endDate,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "offset": offset.toString(),
        "limit": 50.toString(),
        "supplierId": ?supplierId,
        "startDate": ?startDate?.toString(),
        "endDate": ?endDate?.toString(),
        "branchId": currentBranch,
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getEntryHistoryById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
