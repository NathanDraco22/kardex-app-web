import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class ExpenseCategoriesDataSource with HttpService {
  ExpenseCategoriesDataSource._();
  static final ExpenseCategoriesDataSource instance = ExpenseCategoriesDataSource._();
  factory ExpenseCategoriesDataSource() {
    return instance;
  }

  final _endpoint = "/expense-categories";

  Future<Map<String, dynamic>> createExpenseCategory(Map<String, dynamic> body) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, body, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllExpenseCategories() async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getExpenseCategoryById(String expenseCategoryId) async {
    final uri = HttpTools.generateUri("$_endpoint/$expenseCategoryId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateExpenseCategoryById(
    String expenseCategoryId,
    Map<String, dynamic> body,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$expenseCategoryId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: body, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteExpenseCategoryById(String expenseCategoryId) async {
    final uri = HttpTools.generateUri("$_endpoint/$expenseCategoryId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
