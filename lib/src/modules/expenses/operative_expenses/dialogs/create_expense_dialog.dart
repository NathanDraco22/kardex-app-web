import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';
import 'package:kardex_app_front/widgets/dropdown/expense_category_dropdown.dart';

import 'package:kardex_business/kardex_business.dart';

part 'form_section.dart';

Future<ExpenseInDb?> showCreateExpenseDialog(BuildContext context, {ExpenseInDb? expense}) async {
  final writeCubit = context.read<WriteExpenseCubit>();
  final expenseCategoriesRepo = context.read<ExpenseCategoriesRepository>();

  final widget = RepositoryProvider.value(
    value: expenseCategoriesRepo,
    child: BlocProvider.value(
      value: writeCubit,
      child: CreateExpenseDialog(expense: expense),
    ),
  );

  ExpenseInDb? result;

  if (context.isMobile()) {
    result = await Navigator.push<ExpenseInDb?>(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  } else {
    result = await showDialog<ExpenseInDb?>(
      context: context,
      builder: (context) => widget,
    );
  }

  return result;
}

class CreateExpenseDialog extends StatefulWidget {
  const CreateExpenseDialog({
    super.key,
    this.expense,
  });

  final ExpenseInDb? expense;

  @override
  State<CreateExpenseDialog> createState() => _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends State<CreateExpenseDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteExpenseCubit, WriteExpenseState>(
      listener: (context, state) async {
        if (state is WritingExpense) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is ExpenseCreated || state is ExpenseUpdated) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop((state as WriteExpenseSuccess).item);
        }
        if (state is WriteExpenseError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: Form(
        key: formKey,
        child: _FormContent(
          formKey: formKey,
          creationMap: creationMap,
          expense: widget.expense,
        ),
      ),
    );
  }
}
