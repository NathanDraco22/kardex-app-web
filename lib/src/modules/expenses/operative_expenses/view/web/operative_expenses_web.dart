part of '../operative_expenses_screen.dart';

class OperativeExpensesWeb extends StatelessWidget {
  const OperativeExpensesWeb({super.key});

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

          return const _WebBody();
        },
      ),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
            const Expanded(child: ExpensesTable()),
          ],
        ),
      ),
    );
  }
}
