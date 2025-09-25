import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ReceiptsDataSource with HttpService {
  ReceiptsDataSource._();
  static final ReceiptsDataSource instance = ReceiptsDataSource._();
  factory ReceiptsDataSource() {
    return instance;
  }

  final _endpoint = "/receipts";

  Future<Map<String, dynamic>> createReceipt(Map<String, dynamic> receipt) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, receipt, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllReceiptsByClientId(String clientId) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        'clientId': clientId,
        'branchId': currentBranch,
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
