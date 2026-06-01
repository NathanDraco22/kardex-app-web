import 'package:kardex_app_front/src/data/expense_categories_data_source.dart';
import 'package:kardex_app_front/src/domain/models/expense_category_model/expense_category_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExpenseCategoriesRepository {
  final ExpenseCategoriesDataSource expenseCategoriesDataSource;

  ExpenseCategoriesRepository(this.expenseCategoriesDataSource);

  List<ExpenseCategoryInDb> _expenseCategories = [];

  List<ExpenseCategoryInDb> get expenseCategories => _expenseCategories;

  Future<ExpenseCategoryInDb> createExpenseCategory(CreateExpenseCategory createExpenseCategory) async {
    final result = await expenseCategoriesDataSource.createExpenseCategory(createExpenseCategory.toJson());
    final newCategory = ExpenseCategoryInDb.fromJson(result);
    _expenseCategories = [newCategory, ..._expenseCategories];
    return newCategory;
  }

  Future<List<ExpenseCategoryInDb>> getAllExpenseCategories() async {
    final results = await expenseCategoriesDataSource.getAllExpenseCategories();
    final response = ListResponse<ExpenseCategoryInDb>.fromJson(
      results,
      ExpenseCategoryInDb.fromJson,
    );
    _expenseCategories = response.data;
    return _expenseCategories;
  }

  Future<ExpenseCategoryInDb?> getExpenseCategoryById(String expenseCategoryId) async {
    final result = await expenseCategoriesDataSource.getExpenseCategoryById(expenseCategoryId);
    if (result == null) return null;
    return ExpenseCategoryInDb.fromJson(result);
  }

  Future<ExpenseCategoryInDb?> updateExpenseCategoryById(
    String expenseCategoryId,
    UpdateExpenseCategory expenseCategory,
  ) async {
    final result = await expenseCategoriesDataSource.updateExpenseCategoryById(
      expenseCategoryId,
      expenseCategory.toJson(),
    );
    if (result == null) return null;

    final updatedCategory = ExpenseCategoryInDb.fromJson(result);
    final index = _expenseCategories.indexWhere((u) => u.id == expenseCategoryId);
    if (index != -1) {
      _expenseCategories[index] = updatedCategory;
    }
    return updatedCategory;
  }

  Future<ExpenseCategoryInDb?> deleteExpenseCategoryById(String expenseCategoryId) async {
    final result = await expenseCategoriesDataSource.deleteExpenseCategoryById(expenseCategoryId);
    if (result == null) return null;

    final deletedCategory = ExpenseCategoryInDb.fromJson(result);
    _expenseCategories.removeWhere((u) => u.id == expenseCategoryId);
    return deletedCategory;
  }
}
