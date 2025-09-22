import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class InvoicesDataSource with HttpService {
  InvoicesDataSource._();
  static final InvoicesDataSource instance = InvoicesDataSource._();
  factory InvoicesDataSource() {
    return instance;
  }

  final _endpoint = "/invoices";
  final _pendingEndoint = "/invoices/pending";

  Future<Map<String, dynamic>> createInvoice(Map<String, dynamic> invoice) async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, invoice);
    return res;
  }

  Future<Map<String, dynamic>> getInvoicesByClientId(String clientId) async {
    final uri = HttpTools.generateUri("$_endpoint/client/$clientId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> getPendingInvoices(String clientId) async {
    final uri = HttpTools.generateUri("$_pendingEndoint/$clientId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> getPaidInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    required int offset,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      _endpoint,
      queryParameters: {
        "branchId": currentBranch,
        "clientId": ?clientId,
        "startDate": ?startDate?.toString(),
        "endDate": ?endDate?.toString(),
        "byPaidAt": true.toString(),
        "status": "paid",
        "offset": offset.toString(),
      },
    );
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>> getTotalFromPaidInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    required int offset,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      "$_endpoint/totals",
      queryParameters: {
        "branchId": currentBranch,
        "clientId": ?clientId,
        "startDate": ?startDate?.toString(),
        "endDate": ?endDate?.toString(),
        "byPaidAt": true.toString(),
        "status": "paid",
      },
    );
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> getInvoiceById(String invoiceId) async {
    final uri = HttpTools.generateUri("$_endpoint/$invoiceId");
    final res = await getQuery(uri);
    return res;
  }

  Future<Map<String, dynamic>?> updateInvoiceById(
    String invoiceId,
    Map<String, dynamic> invoice,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$invoiceId");
    final res = await patchQuery(uri, body: invoice);
    return res;
  }
}
