import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class SuppliersDataSource with HttpService {
  SuppliersDataSource._();
  static final SuppliersDataSource instance = SuppliersDataSource._();
  factory SuppliersDataSource() {
    return instance;
  }

  final _supplierEndpoint = "/suppliers";

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> supplier) async {
    final uri = HttpTools.generateUri(_supplierEndpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, supplier, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllSuppliers() async {
    final uri = HttpTools.generateUri(_supplierEndpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getSupplierById(String supplierId) async {
    final uri = HttpTools.generateUri("$_supplierEndpoint/$supplierId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> searchSupplierByKeyword(String keyword) async {
    final uri = HttpTools.generateUri("$_supplierEndpoint/search/$keyword");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateSupplierById(
    String supplierId,
    Map<String, dynamic> supplier,
  ) async {
    final uri = HttpTools.generateUri("$_supplierEndpoint/$supplierId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: supplier, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteSupplierById(String supplierId) async {
    final uri = HttpTools.generateUri("$_supplierEndpoint/$supplierId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
