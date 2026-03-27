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
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, invoice, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> createAnonInvoice(Map<String, dynamic> invoice) async {
    final uri = HttpTools.generateUri("$_endpoint/anon");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, invoice, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getInvoicesByClientId(String clientId) async {
    final uri = HttpTools.generateUri("$_endpoint/client/$clientId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllInvoices(Map<String, String> params) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getPendingInvoices(String clientId) async {
    final uri = HttpTools.generateUri("$_pendingEndoint/$clientId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getPaidInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    String? userCreatorId,
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
        "createdBy": ?userCreatorId,
        "byPaidAt": true.toString(),
        "status": "paid",
        "offset": offset.toString(),
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getTotalFromPaidInvoices({
    String? clientId,
    int? startDate,
    int? endDate,
    String? userCreatorId,
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
        "createdBy": ?userCreatorId,
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getClientInvoices({
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
        "offset": offset.toString(),
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getTotalFromClientInvoices(Map<String, String> params) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/totals",
      queryParameters: params,
    );
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllProductSales(Map<String, String> params) async {
    final uri = HttpTools.generateUri("$_endpoint/product-sales", queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getInvoiceById(String invoiceId) async {
    final uri = HttpTools.generateUri("$_endpoint/$invoiceId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateInvoiceById(
    String invoiceId,
    Map<String, dynamic> invoice,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$invoiceId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: invoice, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getInvoicesHistory(Map<String, String> params) async {
    final uri = HttpTools.generateUri("$_endpoint/history", queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getInvoiceByDocNumber(String docNumber) async {
    final uri = HttpTools.generateUri("$_endpoint/doc/$docNumber");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
