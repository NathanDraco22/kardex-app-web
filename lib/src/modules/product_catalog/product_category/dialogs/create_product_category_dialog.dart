import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/product_category/product_category_model.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/cubit/write_product_category_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ProductCategoryInDb?> showCreateProductCategoryDialog(
  BuildContext context, {
  ProductCategoryInDb? category,
}) async {
  final cubit = context.read<WriteProductCategoryCubit>();

  final widget = BlocProvider.value(
    value: cubit,
    child: CreateProductCategoryDialog(
      category: category,
    ),
  );

  final result = await showDialog<ProductCategoryInDb?>(
    context: context,
    builder: (_) => widget,
  );
  return result;
}

class CreateProductCategoryDialog extends StatefulWidget {
  const CreateProductCategoryDialog({
    super.key,
    this.category,
  });

  final ProductCategoryInDb? category;

  @override
  State<CreateProductCategoryDialog> createState() => _CreateProductCategoryDialogState();
}

class _CreateProductCategoryDialogState extends State<CreateProductCategoryDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = {};

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.category;
    final prefixTitle = currentCategory == null ? "Agregar" : "Actualizar";
    return BlocListener<WriteProductCategoryCubit, WriteProductCategoryState>(
      listener: (context, state) {
        if (state is WriteProductCategoryInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteProductCategorySuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.productCategory);
        }

        if (state is WriteProductCategoryError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AlertDialog(
              title: Text("$prefixTitle Categoria de Producto"),
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
                      final createNewCategory = CreateProductCategory.fromJson(creationMap);
                      final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                        context,
                        "¿Desea crear la categoria ${createNewCategory.name}?",
                      );
                      if (!isConfirmed) return;
                      if (!context.mounted) return;
                      context.read<WriteProductCategoryCubit>().createNewProductCategory(createNewCategory);
                    } else {
                      final updateCategory = UpdateProductCategory.fromJson(creationMap);
                      final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                        context,
                        "¿Desea crear la categoria ${updateCategory.name}?",
                      );
                      if (!isConfirmed) return;
                      if (!context.mounted) return;
                      context.read<WriteProductCategoryCubit>().updateProductCategory(
                        currentCategory.id,
                        updateCategory,
                      );
                    }
                  },
                  child: Text(prefixTitle),
                ),
              ],
              content: Column(
                children: [
                  TitleTextField(
                    initialValue: currentCategory?.name,
                    autofocus: true,
                    title: "Nombre de la Categoria*",
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Campo requerido";
                      creationMap['name'] = value.trim();
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
