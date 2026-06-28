import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/read_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/write_expense_categories_cubit.dart';

import '../dialogs/create_expense_category_dialog.dart';
import '../widgets/expense_category_table.dart';

part 'web/expense_category_web.dart';

class ExpenseCategoriesScreen extends StatelessWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseCategoriesRepo = context.read<ExpenseCategoriesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadExpenseCategoryCubit(expenseCategoriesRepo)..getAll(),
        ),
        BlocProvider(create: (context) => WriteExpenseCategoryCubit(expenseCategoriesRepo)),
      ],
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    log(MediaQuery.sizeOf(context).width.toString());
    return const ExpenseCategoryWeb();
  }
}
