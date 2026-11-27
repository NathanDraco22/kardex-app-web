import 'package:kardex_business/src/services/dio_http_service.dart';
import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class ReceiptCancellationRequestsDataSource with HttpService, DioHttpService {
  ReceiptCancellationRequestsDataSource._();
  static final ReceiptCancellationRequestsDataSource instance =
      ReceiptCancellationRequestsDataSource._();
  factory ReceiptCancellationRequestsDataSource() => instance;

  final _endpoint = '/receipt-cancellation-requests';

  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    return postQuery(uri, data, headers: headers);
  }

  Future<Map<String, dynamic>> getAllRequests(Map<String, String> query) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: query);
    final headers = HttpTools.generateAuthHeaders();
    return getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> countPendingRequests({String? branchId}) async {
    final uri = HttpTools.generateUri(
      '$_endpoint/pending/count',
      queryParameters: branchId != null ? {'branchId': branchId} : null,
    );
    final headers = HttpTools.generateAuthHeaders();
    return getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> getRequestById(String id) async {
    final uri = HttpTools.generateUri('$_endpoint/$id');
    final headers = HttpTools.generateAuthHeaders();
    return getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> approveRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$id/approve');
    final headers = HttpTools.generateAuthHeaders();
    return postQuery(uri, data, headers: headers);
  }

  Future<Map<String, dynamic>> rejectRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$id/reject');
    final headers = HttpTools.generateAuthHeaders();
    return postQuery(uri, data, headers: headers);
  }

  Future<Map<String, dynamic>> cancelRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    final uri = HttpTools.generateUri('$_endpoint/$id/cancel');
    final headers = HttpTools.generateAuthHeaders();
    return postQuery(uri, data, headers: headers);
  }
}
