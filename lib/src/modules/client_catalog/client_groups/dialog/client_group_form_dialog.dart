import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client_group/client_group_model.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/cubit/write_client_group_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ClientGroupInDb?> showClientGroupFormDialog(BuildContext context, {ClientGroupInDb? group}) async {
  final cubit = context.read<WriteClientGroupCubit>();

  return await showDialog<ClientGroupInDb?>(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: ClientGroupFormDialog(group: group),
      );
    },
  );
}

class ClientGroupFormDialog extends StatefulWidget {
  const ClientGroupFormDialog({super.key, this.group});

  final ClientGroupInDb? group;

  @override
  State<ClientGroupFormDialog> createState() => _ClientGroupFormDialogState();
}

class _ClientGroupFormDialogState extends State<ClientGroupFormDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.group != null;
    final wordPrefix = isEditing ? "Actualizar" : "Agregar";

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
              title: Text("$wordPrefix Grupo de Clientes"),
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
                      if (isEditing) {
                        final updateGroupData = UpdateClientGroup.fromJson(creationMap);
                        context.read<WriteClientGroupCubit>().updateGroup(widget.group!.id, updateGroupData);
                      } else {
                        final newGroup = CreateClientGroup.fromJson(creationMap);
                        context.read<WriteClientGroupCubit>().createNewGroup(newGroup);
                      }
                    }
                  },
                  child: Text(wordPrefix),
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
                      initialValue: widget.group?.name,
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
                      initialValue: widget.group?.description,
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
