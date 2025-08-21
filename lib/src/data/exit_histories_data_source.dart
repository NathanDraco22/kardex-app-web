import 'package:kardex_app_front/src/services/http_service.dart';
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
    int? limit,
    String? clientId,
    required String branchId,
  }) async {
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "offset": offset.toString(),
        if (limit != null) "limit": limit.toString(),
        if (clientId != null) "clientId": clientId,
        "branchId": branchId,
      },
    );
    final res = await getQuery(uri);
    return res;
  }
}
