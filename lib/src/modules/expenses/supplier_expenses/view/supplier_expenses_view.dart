import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_config.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_list_screen.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/supplier_expense_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

import '../dialogs/create_supplier_expense_dialog.dart';

class SupplierExpenseScreen extends StatelessWidget {
  const SupplierExpenseScreen({super.key});

  static const Color _accentColor = Color(0xFFEA580C);

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
          )..getAll(ExpenseQueryParams()..type = ExpenseType.supplier.name),
        ),
        BlocProvider(
          create: (_) => WriteExpenseCubit(expensesRepo),
        ),
      ],
      child: const _SupplierExpensesScaffold(),
    );
  }
}

class _SupplierExpensesScaffold extends StatelessWidget {
  const _SupplierExpensesScaffold();

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
          title: 'Gastos de Proveedores',
          subtitle: 'Pagos y compras asociadas a proveedores de mercancía y servicios.',
          icon: Icons.storefront_rounded,
          accentColor: SupplierExpenseScreen._accentColor,
          expenseType: ExpenseType.supplier,
          conceptLabel: 'Proveedor',
          searchHint: 'Buscar por proveedor, documento o descripción...',
          emptyTitle: 'Sin gastos de proveedores',
          emptySubtitle: 'Registra tu primer pago a proveedor para llevar el control de compras.',
          createButtonLabel: 'Nuevo Gasto',
          supportsSupplierFilter: true,
          onCreate: (context) => showCreateSupplierExpenseDialog(context),
          onEdit: (context, expense) => showCreateSupplierExpenseDialog(context, expense: expense),
          onOpenViewer: showSupplierExpenseViewerDialog,
        ),
      ),
    );
  }
}
