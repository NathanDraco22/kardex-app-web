import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/cubit/write_branch_cubit.dart';
import 'package:kardex_app_front/src/tools/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<BranchInDb?> showCreateBranchPriceDialog(
  BuildContext context, {
  BranchInDb? branch,
}) async {
  final writeCubit = context.read<WriteBranchCubit>();

  return await showDialog<BranchInDb?>(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: writeCubit,
        child: CreateProductPriceDialog(
          branch: branch,
        ),
      );
    },
  );
}

class CreateProductPriceDialog extends StatefulWidget {
  const CreateProductPriceDialog({super.key, this.branch});

  final BranchInDb? branch;

  @override
  State<CreateProductPriceDialog> createState() => _CreateProductPriceDialogState();
}

class _CreateProductPriceDialogState extends State<CreateProductPriceDialog> {
  final formKey = GlobalKey<FormState>();

  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final currenBranch = widget.branch;
    final prefixTitle = currenBranch == null ? "Agregar" : "Actualizar";
    return BlocListener<WriteBranchCubit, WriteBranchState>(
      listener: (context, state) {
        if (state is WriteBranchInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteBranchSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.branch);
        }

        if (state is WriteBranchError) {
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
              title: Text("$prefixTitle Precio de Producto"),
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

                    if (currenBranch == null) {
                      final newProductPrice = CreateBranch.fromJson(creationMap);

                      final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                        context,
                        "¿Desea agregar Rama/Sucursal ${newProductPrice.name}?",
                      );
                      if (!isConfirmed) return;
                      if (!context.mounted) return;
                      context.read<WriteBranchCubit>().createNewBranch(newProductPrice);
                    } else {
                      final isConfirmed = await DialogManager.slideToConfirmActionDialog(
                        context,
                        "¿Desea actualizar Rama/Sucursal ${currenBranch.name}?",
                      );
                      if (!isConfirmed) return;
                      if (!context.mounted) return;
                      context.read<WriteBranchCubit>().updateBranch(
                        currenBranch.id,
                        UpdateBranch.fromJson(creationMap),
                      );
                    }
                  },
                  child: const Text("Agregar Precio de Producto"),
                ),
              ],
              content: Column(
                children: [
                  TitleTextField(
                    title: "Nombre de Rama/Sucursal*",
                    initialValue: currenBranch?.name,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      creationMap['name'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    title: "Descripción de Rama/Sucursal",
                    initialValue: currenBranch?.description,
                    validator: (value) {
                      if (value == null) return null;
                      creationMap['description'] = value.trim();
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
