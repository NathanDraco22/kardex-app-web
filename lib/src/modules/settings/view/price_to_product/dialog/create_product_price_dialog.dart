import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/product_price/product_price_model.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/cubit/write_product_price_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ProductPriceInDb?> showCreateProductPriceDialog(BuildContext context) async {
  final writeCubit = context.read<WriteProductPriceCubit>();

  return await showDialog<ProductPriceInDb?>(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: writeCubit,
        child: const CreateProductPriceDialog(),
      );
    },
  );
}

class CreateProductPriceDialog extends StatefulWidget {
  const CreateProductPriceDialog({super.key});

  @override
  State<CreateProductPriceDialog> createState() => _CreateProductPriceDialogState();
}

class _CreateProductPriceDialogState extends State<CreateProductPriceDialog> {
  final formKey = GlobalKey<FormState>();

  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteProductPriceCubit, WriteProductPriceState>(
      listener: (context, state) {
        if (state is WriteProductPriceInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteProductPriceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.productPrice);
        }

        if (state is WriteProductPriceError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showInfoDialog(context, state.error);
        }
      },
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AlertDialog(
              title: const Text("Agregar Nuevo Precio de Producto"),
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

                    final newProductPrice = CreateProductPrice.fromJson(creationMap);

                    final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                      context,
                      "¿Desea agregar el precio de producto ${newProductPrice.name}?",
                    );
                    if (!isConfirmed) return;
                    if (!context.mounted) return;
                    context.read<WriteProductPriceCubit>().createNewProductPrice(newProductPrice);
                  },
                  child: const Text("Agregar Precio de Producto"),
                ),
              ],
              content: Column(
                children: [
                  TitleTextField(
                    title: "Nombre del Precio de Producto*",
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      creationMap['name'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
