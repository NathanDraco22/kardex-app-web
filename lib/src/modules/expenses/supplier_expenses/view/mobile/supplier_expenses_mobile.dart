part of '../supplier_expenses_view.dart';

class SupplierExpensesMobile extends StatelessWidget {
  const SupplierExpensesMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gastos de Proveedores")),
      body: BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
        builder: (context, state) {
          if (state is ReadExpenseLoading || state is ReadExpenseInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReadExpenseError) {
            return Center(child: Text(state.message));
          }

          return const _MobileBody();
        },
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadExpenseCubit>();
    final state = cubit.state as ReadExpenseSuccess;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateSupplierExpenseDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      context.read<ReadExpenseCubit>().markExpenseCreated(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Gasto"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SupplierSelector(
                            onSupplierSelected: (selected) {
                              final currentParams = cubit.queryParams;
                              currentParams.supplierId = selected?.id;
                              currentParams.offset = 0;
                              cubit.getAll(currentParams);
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String?>(
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
                    const Divider(),
                    Builder(
                      builder: (context) {
                        if (state.items.isEmpty) {
                          return const Expanded(
                            child: NoItemWidget(
                              icon: Icons.monetization_on,
                              text: "No hay gastos de proveedores",
                            ),
                          );
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final expense = state.items[index];
                              Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                              if (state.deletedItems.any((e) => e.id == expense.id) || expense.isDeleted) {
                                rowColor = Colors.red.shade200;
                              } else if (state.newItems.any((e) => e.id == expense.id)) {
                                rowColor = Colors.yellow.shade200;
                              } else if (state.updatedItems.any((e) => e.id == expense.id)) {
                                rowColor = Colors.blue.shade200;
                              }

                              return _MobileExpenseRow(rowColor: rowColor, expense: expense);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileExpenseRow extends StatelessWidget {
  const _MobileExpenseRow({
    required this.rowColor,
    required this.expense,
  });

  final Color rowColor;
  final ExpenseInDb expense;

  @override
  Widget build(BuildContext context) {
    final readState = context.watch<ReadExpenseCubit>().state;
    final canDelete = DateTime.now().difference(expense.createdAt).inHours < 12;
    final isDeleted =
        expense.isDeleted || (readState is ReadExpenseSuccess && readState.deletedItems.any((e) => e.id == expense.id));

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          expense.supplierName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SupplierStatusBadge(status: expense.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Doc: ${expense.docNumber.isEmpty ? "—" : expense.docNumber}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (expense.expirationDate != null) ...[
                          Text(
                            "Vence: ${DateTimeTool.formatddMMyyEs(
                              DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!),
                            )}",
                            style: TextStyle(
                              fontSize: 13,
                              color: isExpired ? Colors.red.shade700 : Colors.grey.shade600,
                              fontWeight: isExpired ? FontWeight.bold : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          "Creado: ${DateTimeTool.formatddMMyyEs(
                            DateTime.fromMillisecondsSinceEpoch(expense.date),
                          )}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                NumberFormatter.convertFromCentsToUnitsCurrency(expense.amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              isDeleted
                  ? const SizedBox(width: 48)
                  : PopupMenuButton<int>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) async {
                        if (value == 0) {
                          final res = await showCreateSupplierExpenseDialog(context, expense: expense);
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
                            final updated = await context.read<ExpensesRepository>().updateExpenseById(
                              expense.id,
                              UpdateExpense(
                                status: ExpenseStatus.paid,
                                expirationDate: null,
                              ),
                            );
                            if (updated != null) {
                              if (!context.mounted) return;
                              context.read<ReadExpenseCubit>().markExpenseUpdated(updated);
                            }
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
                            final deleted = await context.read<ExpensesRepository>().deleteExpenseById(expense.id);
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
            ],
          ),
        ),
      ),
    );
  }
}
