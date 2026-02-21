import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_list/cubit/client_write_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<ClientInDb?> showCreateClientDialog(BuildContext context, {ClientInDb? client}) async {
  final writeCubit = context.read<WriteClientCubit>();
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
    final writeCubit = context.read<WriteClientCubit>();

    final wordPrefix = widget.client == null ? "Agregar" : "Actualizar";

    bool isActive = true;
    bool isCreditActive = false;

    if (widget.client != null) {
      isActive = widget.client!.isActive;
      isCreditActive = widget.client!.isCreditActive;
    }

    creationMap['isActive'] = isActive;

    final currentClient = widget.client;

    return BlocListener<WriteClientCubit, WriteClientState>(
      listener: (context, state) async {
        if (state is WriteClientInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteClientSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.client);
        }

        if (state is DeleteClientSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(
            context,
            "Se ha borrado el cliente ${state.client.name}",
          );
          if (!context.mounted) return;
          context.pop(state.client);
        }
        if (state is WriteClientError) {
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
                      textCapitalization: TextCapitalization.words,
                      title: "Nombre Completo*",
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                      initialValue: widget.client?.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El campo es requerido";
                        }
                        creationMap["name"] = value.trim();
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
                              if (value == null) {
                                return null;
                              }
                              creationMap["cardId"] = value.trim();
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
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),

                            validator: (value) {
                              if (value == null) {
                                return null;
                              }
                              creationMap["phone"] = value.trim();
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TitleTextField(
                      key: const ValueKey("credit_field"),
                      title: "Limite de Credito(C\$)*",
                      keyboardType: TextInputType.number,
                      inputFormatters: [IntegerThousandsFormatter()],
                      initialValue: widget.client?.creditLimit.toString(),
                      validator: (value) {
                        final formattedValue = value?.replaceAll(RegExp(r'[^0-9]'), "");
                        if (formattedValue == null || formattedValue.isEmpty) {
                          return "El campo es requerido";
                        }

                        final number = int.tryParse(formattedValue.trim());

                        if (number == null) {
                          return "Numero incorrecto";
                        }

                        creationMap["creditLimit"] = number;
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    StatefulBuilder(
                      builder: (context, setState) {
                        return SwitchListTile(
                          focusNode: FocusNode(skipTraversal: true),
                          tileColor: Colors.grey.shade100,
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

                    StatefulBuilder(
                      builder: (context, setState) {
                        return SwitchListTile(
                          focusNode: FocusNode(skipTraversal: true),
                          tileColor: Colors.grey.shade100,
                          value: isCreditActive,
                          onChanged: (value) {
                            isCreditActive = value;
                            creationMap["isCreditActive"] = value;
                            setState(() {});
                          },
                          title: const Text("Credito Activo"),
                        );
                      },
                    ),

                    if (currentClient != null) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              final res = await DialogManager.slideToConfirmDeleteActionDialog(
                                context,
                                "Deseas eliminar el cliente ${currentClient.name}?",
                              );
                              if (!res) return;
                              writeCubit.deleteClient(currentClient.id);
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            label: const Text("Eliminar Cliente"),
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
