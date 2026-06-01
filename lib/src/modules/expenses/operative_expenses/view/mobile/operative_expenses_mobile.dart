part of '../operative_expenses_screen.dart';

class OperativeExpensesMobile extends StatelessWidget {
  const OperativeExpensesMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gastos Operativos")),
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
                      final res = await showCreateExpenseDialog(context);
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
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
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
                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final expense = state.items[index];
                              Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                              if (state.newItems.any((e) => e.id == expense.id)) {
                                rowColor = Colors.yellow.shade200;
                              }

                              if (state.updatedItems.any((e) => e.id == expense.id)) {
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
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.blueGrey.shade700,
                          size: 16,
                        ),
                        Text(
                          expense.docNumber,
                          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expense.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      spacing: 8,
                      children: [
                        _StatusBadge(status: expense.status),
                        if (expense.expirationDate != null) ...[
                          Icon(
                            Icons.event,
                            size: 14,
                            color: isExpired ? Colors.red.shade700 : Colors.grey.shade600,
                          ),
                          Text(
                            DateTimeTool.formatddMMyyEs(
                              DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpired ? Colors.red.shade700 : Colors.grey.shade600,
                              fontWeight: isExpired ? FontWeight.w600 : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Text(
                  NumberFormatter.convertFromCentsToUnitsCurrency(expense.amount),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: .center,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final res = await showCreateExpenseDialog(context, expense: expense);
                      if (res == null) return;
                      if (!context.mounted) return;
                      context.read<ReadExpenseCubit>().markExpenseUpdated(res);
                      if (!context.mounted) return;
                    },
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
