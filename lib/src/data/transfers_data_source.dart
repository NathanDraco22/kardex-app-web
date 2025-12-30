import 'package:kardex_app_front/src/services/dio_http_service.dart';
import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class TransfersDataSource with HttpService, DioHttpService {
  TransfersDataSource._();
  static final TransfersDataSource instance = TransfersDataSource._();
  factory TransfersDataSource() => instance;

  final _endpoint = "/transfers";

  Future<Map<String, dynamic>> createTransfer(Map<String, dynamic> transfer) async {
    final uri = HttpTools.generateUri(_endpoint);

    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(
      uri,
      transfer,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getAllTransfers(Map<String, String> query) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: query);

    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> receiveTransfer(String id, Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/$id/receive");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(
      uri,
      data,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> cancelTransfer(String id, Map<String, dynamic> data) async {
    final uri = HttpTools.generateUri("$_endpoint/$id/cancel");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(
      uri,
      data,
      headers: headers,
    );
    return res;
  }

  Future<Map<String, dynamic>> getTransferById(String id) async {
    final uri = HttpTools.generateUri("$_endpoint/$id");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(
      uri,
      headers: headers,
    );
    return res;
  }
}
