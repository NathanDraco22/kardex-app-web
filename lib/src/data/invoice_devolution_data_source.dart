import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class InvoiceDevolutionsDataSource with HttpService {
  final _endpoint = "/invoice-devolutions";

  Future<Map<String, dynamic>> getAnonInvoicesWithDevlutions(String docNumber) async {
    final uri = HttpTools.generateUri("$_endpoint/anon-invoice-doc-number/$docNumber");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }
}
