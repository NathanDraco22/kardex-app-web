part of '../expense_categories_view.dart';

class ExpenseCategoryWeb extends StatelessWidget {
  const ExpenseCategoryWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebScaffold();
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Categorías de Gastos")),
      body: BlocBuilder<ReadExpenseCategoryCubit, ReadExpenseCategoryState>(
        builder: (context, state) {
          if (state is ReadExpenseCategoryLoading || state is ReadExpenseCategoryInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadExpenseCategoryError) {
            return Center(
              child: Text(state.message),
            );
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateExpenseCategoryDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      context.read<ReadExpenseCategoryCubit>().markExpenseCategoryCreated(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Categoría de Gasto"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: ExpenseCategoryTable(),
            ),
          ],
        ),
      ),
    );
  }
}
