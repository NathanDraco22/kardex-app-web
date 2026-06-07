import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/expense_categories_repository.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/supplier_expense_viewer.dart';
import 'package:kardex_app_front/src/modules/expenses/supplier_expenses/widgets/supplier_selector.dart';
import 'package:kardex_app_front/src/modules/expenses/supplier_expenses/widgets/supplier_expenses_widgets.dart';

import '../dialogs/create_supplier_expense_dialog.dart';

part 'web/supplier_expenses_web.dart';
part 'mobile/supplier_expenses_mobile.dart';

class SupplierExpenseScreen extends StatelessWidget {
  const SupplierExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expensesRepo = context.read<ExpensesRepository>();
    final expenseCategoriesRepo = context.read<ExpenseCategoriesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadExpenseCubit(
            expensesRepo,
            expenseCategoriesRepo,
          )..getAll(ExpenseQueryParams()..type = "supplier"),
        ),
        BlocProvider(
          create: (_) => WriteExpenseCubit(expensesRepo),
        ),
      ],
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteExpenseCubit, WriteExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCreated) {
          context.read<ReadExpenseCubit>().markExpenseCreated(state.item);
        }
        if (state is ExpenseUpdated) {
          context.read<ReadExpenseCubit>().markExpenseUpdated(state.item);
        }
        if (state is ExpenseDeleted) {
          context.read<ReadExpenseCubit>().markExpenseDeleted(state.item);
        }
      },
      child: context.isMobile() ? const SupplierExpensesMobile() : const SupplierExpensesWeb(),
    );
  }
}
