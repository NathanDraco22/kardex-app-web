import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class UnitScalesDataSource with HttpService {
  UnitScalesDataSource._();
  static final UnitScalesDataSource instance = UnitScalesDataSource._();
  factory UnitScalesDataSource() {
    return instance;
  }

  final _endpoint = "/unit-scales";

  Future<Map<String, dynamic>> createUnitScale(Map<String, dynamic> unitScale) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, unitScale, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllUnitScales() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getUnitScaleById(String unitScaleId) async {
    final uri = HttpTools.generateUri("$_endpoint/$unitScaleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateUnitScaleById(
    String unitScaleId,
    Map<String, dynamic> unitScale,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$unitScaleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: unitScale, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteUnitScaleById(String unitScaleId) async {
    final uri = HttpTools.generateUri("$_endpoint/$unitScaleId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
