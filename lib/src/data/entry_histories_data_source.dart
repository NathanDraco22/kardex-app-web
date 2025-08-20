import 'package:kardex_app_front/src/services/http_service.dart';
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
    required String supplierId,
    required String branchId,
  }) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "offset": offset.toString(),
        if (limit != null) "limit": limit.toString(),
        "supplierId": supplierId,
        "branchId": branchId,
      },
    );
    final res = await getQuery(uri);
    return res;
  }
}
