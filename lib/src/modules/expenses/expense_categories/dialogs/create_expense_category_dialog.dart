import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/expense_category_model/expense_category_model.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/write_expense_categories_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ExpenseCategoryInDb?> showCreateExpenseCategoryDialog(
  BuildContext context, {
  ExpenseCategoryInDb? category,
}) async {
  final cubit = context.read<WriteExpenseCategoryCubit>();

  final widget = BlocProvider.value(
    value: cubit,
    child: CreateExpenseCategoryDialog(
      category: category,
    ),
  );

  final result = await showDialog<ExpenseCategoryInDb?>(
    context: context,
    builder: (_) => widget,
  );
  return result;
}

class CreateExpenseCategoryDialog extends StatefulWidget {
  const CreateExpenseCategoryDialog({
    super.key,
    this.category,
  });

  final ExpenseCategoryInDb? category;

  @override
  State<CreateExpenseCategoryDialog> createState() => _CreateExpenseCategoryDialogState();
}

class _CreateExpenseCategoryDialogState extends State<CreateExpenseCategoryDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.category;
    final prefixTitle = currentCategory == null ? "Agregar" : "Actualizar";
    return BlocListener<WriteExpenseCategoryCubit, WriteExpenseCategoryState>(
      listener: (context, state) {
        if (state is WritingExpenseCategory) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteExpenseCategorySuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.item);
        }

        if (state is WriteExpenseCategoryError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AlertDialog(
              title: Text("$prefixTitle Categoría de Gasto"),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    if (currentCategory == null) {
                      final createNewCategory = CreateExpenseCategory.fromJson(creationMap);
                      final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                        context,
                        "¿Desea crear la categoría ${createNewCategory.name}?",
                      );
                      if (!isConfirmed) return;
                      if (!context.mounted) return;
                      context.read<WriteExpenseCategoryCubit>().create(createNewCategory);
                    } else {
                      final updateCategory = UpdateExpenseCategory.fromJson(creationMap);
                      final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                        context,
                        "¿Desea actualizar la categoría ${updateCategory.name ?? currentCategory.name}?",
                      );
                      if (!isConfirmed) return;
                      if (!context.mounted) return;
                      context.read<WriteExpenseCategoryCubit>().update(
                        currentCategory.id,
                        updateCategory,
                      );
                    }
                  },
                  child: Text(prefixTitle),
                ),
              ],
              content: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleTextField(
                      initialValue: currentCategory?.name,
                      autofocus: true,
                      title: "Nombre de la Categoría*",
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Campo requerido";
                        creationMap['name'] = value.trim();
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TitleTextField(
                      initialValue: currentCategory?.description,
                      title: "Descripción",
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (value) {
                        creationMap['description'] = value?.trim();
                        return null;
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
