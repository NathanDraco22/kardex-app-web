import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

import '../dialogs/create_expense_dialog.dart';

class ExpensesTable extends StatelessWidget {
  const ExpensesTable({super.key});

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
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey(cubit.queryParams.status),
                    initialValue: cubit.queryParams.status,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Estado"),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text("Todos"),
                      ),
                      DropdownMenuItem(
                        value: 'open',
                        child: Text("Pendiente"),
                      ),
                      DropdownMenuItem(
                        value: 'paid',
                        child: Text("Pagado"),
                      ),
                    ],
                    onChanged: (value) {
                      final currentParams = cubit.queryParams;
                      currentParams.status = value;
                      currentParams.offset = 0;
                      cubit.getAll(currentParams);
                    },
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
              return const ExpensesRows();
            },
          ),
        ],
      ),
    );
  }
}

class ExpensesRows extends StatelessWidget {
  const ExpensesRows({super.key});

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
          final canDelete = DateTime.now().difference(expense.createdAt).inHours < 12;
          Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

          if (state.deletedItems.any((e) => e.id == expense.id) || expense.isDeleted) {
            rowColor = Colors.red.shade200;
          } else if (state.newItems.any((e) => e.id == expense.id)) {
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
                        child: StatusBadge(status: expense.status),
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
                        child: (expense.isDeleted || state.deletedItems.any((e) => e.id == expense.id))
                            ? const SizedBox()
                            : PopupMenuButton<int>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 0) {
                                    final res = await showCreateExpenseDialog(context, expense: expense);
                                    if (res == null) return;
                                    if (!context.mounted) return;
                                    context.read<ReadExpenseCubit>().markExpenseUpdated(res);
                                  } else if (value == 1) {
                                    final confirmed = await DialogManager.slideToConfirmActionDialog(
                                      context,
                                      "¿Deseas marcar este gasto como pagado?",
                                    );
                                    if (confirmed != true) return;
                                    if (!context.mounted) return;
                                    LoadingDialogManager.showLoadingDialog(context);
                                    try {
                                      await context.read<WriteExpenseCubit>().update(
                                        expense.id,
                                        UpdateExpense(
                                          status: ExpenseStatus.paid,
                                          expirationDate: null,
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      DialogManager.showErrorDialog(context, e.toString());
                                    } finally {
                                      if (context.mounted) {
                                        LoadingDialogManager.closeLoadingDialog(context);
                                      }
                                    }
                                  } else if (value == 2) {
                                    final confirmed = await DialogManager.slideToConfirmActionDialog(
                                      context,
                                      "¿Deseas eliminar este gasto?",
                                    );
                                    if (confirmed != true) return;
                                    if (!context.mounted) return;
                                    LoadingDialogManager.showLoadingDialog(context);
                                    try {
                                      final deleted = await context.read<ExpensesRepository>().deleteExpenseById(
                                        expense.id,
                                      );
                                      if (deleted != null) {
                                        if (!context.mounted) return;
                                        context.read<ReadExpenseCubit>().markExpenseDeleted(deleted);
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      DialogManager.showErrorDialog(context, e.toString());
                                    } finally {
                                      if (context.mounted) {
                                        LoadingDialogManager.closeLoadingDialog(context);
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 0,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text("Editar"),
                                      ],
                                    ),
                                  ),
                                  if (expense.status == ExpenseStatus.open)
                                    const PopupMenuItem(
                                      value: 1,
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text("Marcar como Pagado"),
                                        ],
                                      ),
                                    ),
                                  if (canDelete)
                                    const PopupMenuItem(
                                      value: 2,
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text("Eliminar", style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                ],
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

class StatusBadge extends StatelessWidget {
  final ExpenseStatus status;

  const StatusBadge({super.key, required this.status});

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
