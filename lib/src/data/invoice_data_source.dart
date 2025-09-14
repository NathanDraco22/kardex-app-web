import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class InvoicesDataSource with HttpService {
  InvoicesDataSource._();
  static final InvoicesDataSource instance = InvoicesDataSource._();
  factory InvoicesDataSource() {
    return instance;
  }

  final _endpoint = "/invoices";

  Future<Map<String, dynamic>> createInvoice(Map<String, dynamic> invoice) async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await postQuery(uri, invoice);
    return res;
  }

  Future<Map<String, dynamic>> getPaginatedInvoices({
    required int offset,
    String? clientId,
    String? startDate,
    String? endDate,
  }) async {
    final currentBranch = BranchesTool.getCurrentBranchId();
    final uri = HttpTools.generateUri(
      "$_endpoint/paginated",
      queryParameters: {
        "offset": offset.toString(),
        "limit": paginationItems.toString(),
        "clientId": ?clientId,
        "startDate": ?startDate,
        "endDate": ?endDate,
        "branchId": currentBranch,
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
