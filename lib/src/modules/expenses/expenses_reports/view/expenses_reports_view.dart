import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/expenses/expenses_reports/widgets/expenses_reports_widgets.dart';
import 'package:kardex_app_front/widgets/no_item.dart';

part 'web/expenses_reports_web.dart';
part 'mobile/expenses_reports_mobile.dart';

class ExpensesReportScreen extends StatelessWidget {
  const ExpensesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expensesRepo = context.read<ExpensesRepository>();
    final expenseCategoriesRepo = context.read<ExpenseCategoriesRepository>();
    final today = DateTime.now();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadExpenseCubit(
            expensesRepo,
            expenseCategoriesRepo,
          )..getAll(
              ExpenseQueryParams()
                ..branchId = getIt<AuthCubit>().currentBranchId
                ..startDate = today.startOfDay().millisecondsSinceEpoch
                ..endDate = today.endOfDay().millisecondsSinceEpoch,
            ),
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
    return context.isMobile()
        ? const ExpensesReportsMobile()
        : const ExpensesReportsWeb();
  }
}
