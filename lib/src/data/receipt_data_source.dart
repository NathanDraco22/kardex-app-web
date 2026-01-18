import 'package:kardex_app_front/src/services/http_service.dart';
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

  Future<Map<String, dynamic>> getAllReceipts(Map<String, String> queryParams) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getReceiptsByInvoiceId(String invoiceId) async {
    final uri = HttpTools.generateUri("$_endpoint/invoice/$invoiceId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getReceiptTotal(Map<String, String> queryParams) async {
    final uri = HttpTools.generateUri("$_endpoint/totals", queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getReceiptByDocNumber(String docNumber) async {
    final uri = HttpTools.generateUri("$_endpoint/doc/$docNumber");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getReceiptHistory(Map<String, String> queryParams) async {
    final uri = HttpTools.generateUri("$_endpoint/history", queryParameters: queryParams);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
