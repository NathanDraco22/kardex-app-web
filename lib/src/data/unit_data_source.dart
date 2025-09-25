import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class UnitsDataSource with HttpService {
  UnitsDataSource._();
  static final UnitsDataSource instance = UnitsDataSource._();
  factory UnitsDataSource() {
    return instance;
  }

  final _endpoint = "/units";

  Future<Map<String, dynamic>> createUnit(Map<String, dynamic> unit) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, unit, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllUnits() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getUnitById(String unitId) async {
    final uri = HttpTools.generateUri("$_endpoint/$unitId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchUnitByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_endpoint/search/$keyword");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateUnitById(
    String unitId,
    Map<String, dynamic> unit,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$unitId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: unit, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteUnitById(String unitId) async {
    final uri = HttpTools.generateUri("$_endpoint/$unitId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
