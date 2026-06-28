import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

import 'package:kardex_app_front/widgets/dialogs/selectors/supplier_selection_dialog.dart';

part 'supplier_form_section.dart';

Future<ExpenseInDb?> showCreateSupplierExpenseDialog(BuildContext context, {ExpenseInDb? expense}) async {
  final writeCubit = context.read<WriteExpenseCubit>();

  final widget = BlocProvider.value(
    value: writeCubit,
    child: CreateSupplierExpenseDialog(expense: expense),
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

class CreateSupplierExpenseDialog extends StatefulWidget {
  const CreateSupplierExpenseDialog({
    super.key,
    this.expense,
  });

  final ExpenseInDb? expense;

  @override
  State<CreateSupplierExpenseDialog> createState() => _CreateSupplierExpenseDialogState();
}

class _CreateSupplierExpenseDialogState extends State<CreateSupplierExpenseDialog> {
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
        child: _SupplierFormContent(
          formKey: formKey,
          creationMap: creationMap,
          expense: widget.expense,
        ),
      ),
    );
  }
}
