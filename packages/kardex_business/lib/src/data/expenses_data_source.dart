import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class ExpensesDataSource with HttpService {
  ExpensesDataSource._();
  static final ExpensesDataSource instance = ExpensesDataSource._();
  factory ExpensesDataSource() {
    return instance;
  }

  final _endpoint = "/expenses";

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> expense) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, expense, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> getAllExpenses(Map<String, String> params) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> getExpenseById(String expenseId) async {
    final uri = HttpTools.generateUri("$_endpoint/$expenseId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await getQuery(uri, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> updateExpenseById(
    String expenseId,
    Map<String, dynamic> expense,
  ) async {
    final uri = HttpTools.generateUri("$_endpoint/$expenseId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await patchQuery(uri, body: expense, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>> addToAmountPaid(Map<String, dynamic> body) async {
    final uri = HttpTools.generateUri("$_endpoint/add-to-amount-paid");
    final headers = HttpTools.generateAuthHeaders();
    final res = await postQuery(uri, body, headers: headers);
    return res;
  }

  Future<Map<String, dynamic>?> deleteExpenseById(String expenseId) async {
    final uri = HttpTools.generateUri("$_endpoint/$expenseId");
    final headers = HttpTools.generateAuthHeaders();
    final res = await deleteQuery(uri, headers: headers);
    return res;
  }
}
