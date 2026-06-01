import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/read_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/expense_categories/dialogs/create_expense_category_dialog.dart';

class ExpenseCategoryTable extends StatelessWidget {
  const ExpenseCategoryTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadExpenseCategoryCubit>();
    final state = cubit.state as ReadExpenseCategorySuccess;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: state.items.length,

              itemBuilder: (context, index) {
                final currentExpenseCategory = state.items[index];

                Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                if (state.updatedItems.any((element) => element.id == currentExpenseCategory.id)) {
                  rowColor = Colors.indigo.shade200;
                } else if (state.newItems.any((element) => element.id == currentExpenseCategory.id)) {
                  rowColor = Colors.yellow.shade200;
                }

                return ListTile(
                  minTileHeight: 64,
                  tileColor: rowColor,
                  title: Text(currentExpenseCategory.name),
                  subtitle: currentExpenseCategory.description != null && currentExpenseCategory.description!.isNotEmpty
                      ? Text(currentExpenseCategory.description!)
                      : null,
                  trailing: IconButton(
                    onPressed: () async {
                      final res = await showCreateExpenseCategoryDialog(
                        context,
                        category: currentExpenseCategory,
                      );
                      if (res == null) return;
                      if (!context.mounted) return;
                      context.read<ReadExpenseCategoryCubit>().markExpenseCategoryUpdated(res);
                    },
                    icon: const Icon(
                      Icons.edit,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
