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
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/modules/expenses/operative_expenses/widgets/operative_expenses_widgets.dart';

import '../dialogs/create_expense_dialog.dart';

part 'web/operative_expenses_web.dart';
part 'mobile/operative_expenses_mobile.dart';

class OperativeExpenseScreen extends StatelessWidget {
  const OperativeExpenseScreen({super.key});

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
          )..getAll(ExpenseQueryParams()..type = "operative"),
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
      child: context.isMobile() ? const OperativeExpensesMobile() : const OperativeExpensesWeb(),
    );
  }
}
