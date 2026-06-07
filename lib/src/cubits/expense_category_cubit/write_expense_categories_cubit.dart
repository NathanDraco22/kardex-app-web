import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expense_category_model/expense_category_model.dart';
import 'package:kardex_app_front/src/domain/repositories/expense_categories_repository.dart';

part 'write_expense_categories_state.dart';

class WriteExpenseCategoryCubit extends Cubit<WriteExpenseCategoryState> {
  WriteExpenseCategoryCubit(this.expenseCategoriesRepository) : super(WriteExpenseCategoryInitial());

  final ExpenseCategoriesRepository expenseCategoriesRepository;

  Future<void> create(CreateExpenseCategory createExpenseCategory) async {
    emit(WritingExpenseCategory());
    try {
      final category = await expenseCategoriesRepository.createExpenseCategory(createExpenseCategory);
      emit(ExpenseCategoryCreated(category));
      emit(WriteExpenseCategoryInitial());
    } catch (error) {
      emit(WriteExpenseCategoryError(error.toString()));
    }
  }

  Future<void> update(String expenseCategoryId, UpdateExpenseCategory expenseCategory) async {
    emit(WritingExpenseCategory());
    try {
      final updated = await expenseCategoriesRepository.updateExpenseCategoryById(expenseCategoryId, expenseCategory);
      if (updated != null) {
        emit(ExpenseCategoryUpdated(updated));
        emit(WriteExpenseCategoryInitial());
      }
    } catch (error) {
      emit(WriteExpenseCategoryError(error.toString()));
    }
  }

  Future<void> delete(String expenseCategoryId) async {
    emit(WritingExpenseCategory());
    try {
      final deleted = await expenseCategoriesRepository.deleteExpenseCategoryById(expenseCategoryId);
      if (deleted != null) {
        emit(ExpenseCategoryDeleted(deleted));
        emit(WriteExpenseCategoryInitial());
      }
    } catch (error) {
      emit(WriteExpenseCategoryError(error.toString()));
    }
  }
}
