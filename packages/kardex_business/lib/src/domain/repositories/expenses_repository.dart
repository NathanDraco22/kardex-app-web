import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/expense/expense_model.dart';
import 'package:kardex_business/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';

class ExpensesRepository {
  final ExpensesDataSource expensesDataSource;

  ExpensesRepository(this.expensesDataSource);

  List<ExpenseInDb> _expenses = [];

  List<ExpenseInDb> get expenses => _expenses;

  Future<ExpenseInDb> createExpense(CreateExpense createExpense) async {
    final result = await expensesDataSource.createExpense(createExpense.toJson());
    final newExpense = ExpenseInDb.fromJson(result);
    _expenses = [newExpense, ..._expenses];
    return newExpense;
  }

  Future<List<ExpenseInDb>> getAllExpenses(ExpenseQueryParams params) async {
    final results = await expensesDataSource.getAllExpenses(params.toMap());
    final response = ListResponse<ExpenseInDb>.fromJson(
      results,
      ExpenseInDb.fromJson,
    );
    _expenses = response.data;
    return response.data;
  }

  Future<ExpenseInDb?> getExpenseById(String expenseId) async {
    final result = await expensesDataSource.getExpenseById(expenseId);
    if (result == null) return null;
    return ExpenseInDb.fromJson(result);
  }

  Future<ExpenseInDb?> updateExpenseById(
    String expenseId,
    UpdateExpense expense,
  ) async {
    final result = await expensesDataSource.updateExpenseById(
      expenseId,
      expense.toJson(),
    );
    if (result == null) return null;

    final updatedExpense = ExpenseInDb.fromJson(result);
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      _expenses[index] = updatedExpense;
    }
    return updatedExpense;
  }

  Future<ExpenseInDb> addToAmountPaid(AddToAmountRequest request) async {
    final result = await expensesDataSource.addToAmountPaid(request.toJson());
    final updatedExpense = ExpenseInDb.fromJson(result);
    final index = _expenses.indexWhere((e) => e.id == request.expenseId);
    if (index != -1) {
      _expenses[index] = updatedExpense;
    }
    return updatedExpense;
  }

  Future<ExpenseInDb?> deleteExpenseById(String expenseId) async {
    final result = await expensesDataSource.deleteExpenseById(expenseId);
    if (result == null) return null;

    final deletedExpense = ExpenseInDb.fromJson(result);
    _expenses.removeWhere((e) => e.id == expenseId);
    return deletedExpense;
  }
}
