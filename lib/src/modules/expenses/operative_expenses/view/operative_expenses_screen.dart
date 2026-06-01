import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

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
    final screenSize = MediaQuery.sizeOf(context);
    if (screenSize.width < maxPhoneScreenWidth) {
      return const OperativeExpensesMobile();
    }
    return const OperativeExpensesWeb();
  }
}

class _ExpensesTable extends StatelessWidget {
  const _ExpensesTable();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadExpenseCubit>();
    final state = cubit.state as ReadExpenseSuccess;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  child: SearchFieldDebounced(
                    onSearch: (value) => cubit.searchByKeyword(value),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
            builder: (context, state) {
              if (state is! ReadExpenseSearching) return const SizedBox();
              return const LinearProgressIndicator();
            },
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(flex: 3, fit: FlexFit.tight, child: Text("Categoría")),
                Flexible(flex: 2, fit: FlexFit.tight, child: Text("N° Documento")),
                Flexible(flex: 2, fit: FlexFit.tight, child: Text("Monto")),
                Flexible(flex: 2, fit: FlexFit.tight, child: Text("Estado")),
                Flexible(flex: 2, fit: FlexFit.tight, child: Text("Vencimiento")),
                Flexible(flex: 1, fit: FlexFit.tight, child: SizedBox()),
              ],
            ),
          ),
          const Divider(),
          Builder(
            builder: (context) {
              if (state.items.isEmpty) {
                return const Expanded(
                  child: NoItemWidget(
                    icon: Icons.monetization_on,
                    text: "No hay gastos operativos",
                  ),
                );
              }
              return const _ExpensesRows();
            },
          ),
        ],
      ),
    );
  }
}

class _ExpensesRows extends StatelessWidget {
  const _ExpensesRows();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadExpenseCubit>();
    final state = cubit.state as ReadExpenseSuccess;
    final items = state.items;
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final expense = items[index];
          Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

          if (state.newItems.any((e) => e.id == expense.id)) {
            rowColor = Colors.yellow.shade200;
          } else if (state.updatedItems.any((e) => e.id == expense.id)) {
            rowColor = Colors.blue.shade200;
          }

          final isExpired =
              expense.expirationDate != null &&
              DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!).isBefore(DateTime.now()) &&
              expense.status != ExpenseStatus.paid &&
              expense.status != ExpenseStatus.cancelled;

          return Material(
            color: Colors.transparent,
            child: Ink(
              color: rowColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Text(expense.category, style: const TextStyle(fontSize: 16)),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(expense.docNumber, style: const TextStyle(fontSize: 16)),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(
                        NumberFormatter.convertToMoneyLike(expense.amount),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusBadge(status: expense.status),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: expense.expirationDate != null
                          ? Text(
                              DateTimeTool.formatddMMyyEs(
                                DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: isExpired ? Colors.red.shade700 : null,
                                fontWeight: isExpired ? FontWeight.w600 : null,
                              ),
                            )
                          : const Text("—"),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () async {
                            final res = await showCreateExpenseDialog(context, expense: expense);
                            if (res == null) return;
                            if (!context.mounted) return;
                            context.read<ReadExpenseCubit>().markExpenseUpdated(res);
                            if (!context.mounted) return;
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ExpenseStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        constraints: const BoxConstraints(minWidth: 80),
        decoration: BoxDecoration(
          color: _statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
        ),
        child: Text(
          _statusLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _statusColor,
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case ExpenseStatus.draft:
        return Colors.grey;
      case ExpenseStatus.open:
        return Colors.orange;
      case ExpenseStatus.paid:
        return Colors.green;
      case ExpenseStatus.partiallyPaid:
        return Colors.blue;
      case ExpenseStatus.cancelled:
        return Colors.red;
    }
  }

  String get _statusLabel {
    switch (status) {
      case ExpenseStatus.draft:
        return "Borrador";
      case ExpenseStatus.open:
        return "Pendiente";
      case ExpenseStatus.paid:
        return "Pagado";
      case ExpenseStatus.partiallyPaid:
        return "Parcial";
      case ExpenseStatus.cancelled:
        return "Cancelado";
    }
  }
}
