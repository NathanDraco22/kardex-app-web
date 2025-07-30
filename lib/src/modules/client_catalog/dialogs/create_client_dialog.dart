import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cubit/write_client_catalog_cubit.dart';
import 'package:kardex_app_front/src/tools/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ClientInDb?> showCreateClientDialog(BuildContext context, {ClientInDb? client}) async {
  final writeCubit = context.read<ClientWriteCubit>();
  final res = await showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: writeCubit,
        child: WriteClientDialog(
          client: client,
        ),
      );
    },
  );

  return res;
}

class WriteClientDialog extends StatefulWidget {
  const WriteClientDialog({
    super.key,
    this.client,
  });

  final ClientInDb? client;

  @override
  State<WriteClientDialog> createState() => _WriteClientDialogState();
}

class _WriteClientDialogState extends State<WriteClientDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = {};

  @override
  Widget build(BuildContext context) {
    final wordPrefix = widget.client == null ? "Agregar" : "Actualizar";

    bool isActive = true;

    if (widget.client != null) {
      isActive = widget.client!.isActive;
    }

    creationMap['isActive'] = isActive;

    return BlocListener<ClientWriteCubit, ClientWriteState>(
      listener: (context, state) {
        if (state is ClientWriteInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is ClientWriteSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.client);
        }
        if (state is ClientWriteError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }
      },
      child: Form(
        key: formKey,
        child: AlertDialog(
          title: Text("$wordPrefix Cliente"),
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

                final writeCubit = context.read<ClientWriteCubit>();

                if (widget.client == null) {
                  final createClient = CreateClient.fromJson(creationMap);
                  writeCubit.createNewClient(createClient);
                } else {
                  final updateClient = UpdateClient.fromJson(creationMap);
                  writeCubit.updateClient(widget.client!.id, updateClient);
                }
              },
              child: Text("$wordPrefix Cliente"),
            ),
          ],
          content: SizedBox(
            width: 350,

            child: Column(
              children: [
                TitleTextField(
                  key: const ValueKey("name_field"),
                  autofocus: true,
                  title: "Nombre Completo*",
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  initialValue: widget.client?.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El campo es requerido";
                    }
                    creationMap["name"] = value;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: TitleTextField(
                        key: const ValueKey("cardId_field"),
                        initialValue: widget.client?.cardId,
                        title: "Cedula",
                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                        validator: (value) {
                          creationMap["cardId"] = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: TitleTextField(
                        key: const ValueKey("phone_field"),
                        initialValue: widget.client?.phone,
                        title: "Telefono",
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
