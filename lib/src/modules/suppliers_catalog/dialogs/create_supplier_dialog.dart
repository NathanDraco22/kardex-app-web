import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/cubit/supplier_write_cubit.dart';
import 'package:kardex_app_front/src/tools/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<SupplierInDb?> showCreateSupplierDialog(BuildContext context, {SupplierInDb? supplier}) async {
  final writeCubit = context.read<SupplierWriteCubit>();
  final res = await showDialog<SupplierInDb>(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: writeCubit,
        child: CreateSupplierDialog(
          supplier: supplier,
        ),
      );
    },
  );

  return res;
}

class CreateSupplierDialog extends StatefulWidget {
  const CreateSupplierDialog({
    super.key,
    this.supplier,
  });

  final SupplierInDb? supplier;

  @override
  State<CreateSupplierDialog> createState() => _CreateSupplierDialogState();
}

class _CreateSupplierDialogState extends State<CreateSupplierDialog> {
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> creationMap = {};

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<SupplierWriteCubit>();

    final wordPrefix = widget.supplier == null ? "Agregar" : "Actualizar";

    bool isActive = true;

    if (widget.supplier != null) {
      isActive = widget.supplier!.isActive;
    }

    creationMap['isActive'] = isActive;

    final currentSupplier = widget.supplier;

    return BlocListener<SupplierWriteCubit, SupplierWriteState>(
      listener: (context, state) async {
        if (state is SupplierWriteInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is SupplierWriteSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.supplier);
        }

        if (state is SupplierDeleteSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Se ha borrado el proveedor ${state.supplier.name}");
          if (!context.mounted) return;
          context.pop(state.supplier);
        }

        if (state is SupplierWriteError) {
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
              title: Text("$wordPrefix Proveedor"),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    if (widget.supplier == null) {
                      final createSupplier = CreateSupplier.fromJson(creationMap);
                      writeCubit.createNewSupplier(createSupplier);
                    } else {
                      final updateSupplier = UpdateSupplier.fromJson(creationMap);
                      writeCubit.updateSupplier(widget.supplier!.id, updateSupplier);
                    }
                  },
                  child: Text("$wordPrefix Proveedor"),
                ),
              ],
              content: SizedBox(
                width: 400,

                child: Column(
                  children: [
                    TitleTextField(
                      key: const ValueKey("name_field"),
                      title: "Nombre*",
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                      initialValue: widget.supplier?.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El campo es requerido";
                        }
                        creationMap["name"] = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    TitleTextField(
                      key: const ValueKey("cardId_field"),
                      title: "Cedula/Ruc",
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                      initialValue: widget.supplier?.cardId,
                      validator: (value) {
                        creationMap["cardId"] = value;
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Flexible(
                          child: TitleTextField(
                            key: const ValueKey("email_field"),
                            initialValue: widget.supplier?.email,
                            title: "Email",
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            validator: (value) {
                              creationMap["email"] = value;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: TitleTextField(
                            key: const ValueKey("phone_field"),
                            initialValue: widget.supplier?.phone,
                            title: "Telefono",
                            onEditingComplete: () async {
                              if (widget.supplier != null) return;
                              if (!formKey.currentState!.validate()) return;
                              final res = await DialogManager.confirmActionDialog(
                                context,
                                "Deseas crear el proveedor ${creationMap["name"]}?",
                              );
                              if (!res) return;
                              final createSupplier = CreateSupplier.fromJson(creationMap);
                              writeCubit.createNewSupplier(createSupplier);
                            },
                            validator: (value) {
                              creationMap["phone"] = value;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return SwitchListTile(
                          focusNode: FocusNode(skipTraversal: true),
                          value: isActive,
                          onChanged: (value) {
                            isActive = value;
                            creationMap["isActive"] = value;
                            setState(() {});
                          },
                          title: const Text("Activo"),
                        );
                      },
                    ),

                    if (currentSupplier != null) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              final res = await DialogManager.slideToConfirmDeleteActionDialog(
                                context,
                                "Deseas eliminar el proveedor ${currentSupplier.name}?",
                              );
                              if (!res) return;
                              writeCubit.deleteSupplier(currentSupplier.id);
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            label: const Text("Eliminar Proveedor"),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
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
