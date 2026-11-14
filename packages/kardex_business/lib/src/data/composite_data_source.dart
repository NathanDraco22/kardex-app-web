import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class CompositeDataSource with HttpService {
  CompositeDataSource._();
  static final CompositeDataSource instance = CompositeDataSource._();
  factory CompositeDataSource() {
    return instance;
  }

  final _endpoint = "/composite";

  Future<Map<String, dynamic>> getClientPendingInvoices({
    required String clientId,
    required String branchId,
  }) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/client-pending-invoices",
      queryParameters: {
        'clientId': clientId,
        'branchId': branchId,
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> getShiftArqueo({
    required String shiftId,
    bool includeDocuments = true,
    int documentsLimit = 500,
  }) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/shift-arqueo/$shiftId",
      queryParameters: {
        'includeDocuments': includeDocuments.toString(),
        'documentsLimit': documentsLimit.toString(),
      },
    );
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }
}
