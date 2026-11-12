import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_screen.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/operative_expense_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

import '../dialogs/create_expense_dialog.dart';

class OperativeExpenseScreen extends StatelessWidget {
  const OperativeExpenseScreen({super.key});

  static const Color _accentColor = Color(0xFF16A34A);

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
          )..getAll(ExpenseQueryParams()..type = ExpenseType.operative.name),
        ),
        BlocProvider(
          create: (_) => WriteExpenseCubit(expensesRepo),
        ),
      ],
      child: const _OperativeExpensesScaffold(),
    );
  }
}

class _OperativeExpensesScaffold extends StatelessWidget {
  const _OperativeExpensesScaffold();

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
      child: ExpenseListScreen(
        config: ExpenseListConfig(
          title: 'Gastos Operativos',
          subtitle: 'Controla los egresos diarios de caja, servicios y mantenimiento.',
          icon: Icons.account_balance_wallet_rounded,
          accentColor: OperativeExpenseScreen._accentColor,
          expenseType: ExpenseType.operative,
          conceptLabel: 'Categoría',
          searchHint: 'Buscar por categoría, documento o descripción...',
          emptyTitle: 'Sin gastos operativos',
          emptySubtitle: 'Registra tu primer egreso operativo para empezar a controlar la caja.',
          createButtonLabel: 'Nuevo Gasto',
          supportsCategoryFilter: true,
          onCreate: (context) => showCreateExpenseDialog(context),
          onEdit: (context, expense) => showCreateExpenseDialog(context, expense: expense),
          onOpenViewer: showOperativeExpenseViewerDialog,
        ),
      ),
    );
  }
}
