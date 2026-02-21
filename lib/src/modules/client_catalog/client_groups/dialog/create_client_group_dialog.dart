import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client_group/client_group_model.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/cubit/write_client_group_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ClientGroupInDb?> showCreateClientGroupDialog(BuildContext context) async {
  final cubit = context.read<WriteClientGroupCubit>();

  return await showDialog<ClientGroupInDb?>(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: const CreateClientGroupDialog(),
      );
    },
  );
}

class CreateClientGroupDialog extends StatefulWidget {
  const CreateClientGroupDialog({super.key});

  @override
  State<CreateClientGroupDialog> createState() => _CreateClientGroupDialogState();
}

class _CreateClientGroupDialogState extends State<CreateClientGroupDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteClientGroupCubit, WriteClientGroupState>(
      listener: (context, state) {
        if (state is WriteClientGroupInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteClientGroupSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.clientGroup);
        }

        if (state is WriteClientGroupError) {
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
              title: const Text("Agregar Nuevo Grupo de Clientes"),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newGroup = CreateClientGroup.fromJson(creationMap);
                      context.read<WriteClientGroupCubit>().createNewGroup(newGroup);
                    }
                  },
                  child: const Text("Agregar Grupo"),
                ),
              ],
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleTextField(
                      title: "Nombre del Grupo*",
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "El nombre es requerido";
                        creationMap['name'] = value.trim();
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TitleTextField(
                      title: "Descripción",
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      validator: (value) {
                        creationMap['description'] = value?.trim() ?? "";
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
