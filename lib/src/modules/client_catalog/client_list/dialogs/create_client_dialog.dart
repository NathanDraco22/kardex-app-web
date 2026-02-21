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

  final res = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return BlocProvider.value(
          value: writeCubit,
          child: WriteClientDialog(
            client: client,
          ),
        );
      },
    ),
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

  bool isActive = true;
  bool isCreditActive = true;
  int creditLimit = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<WriteClientCubit>();

    final wordPrefix = widget.client == null ? "Agregar" : "Actualizar";

    if (widget.client != null) {
      isActive = widget.client!.isActive;
      isCreditActive = widget.client!.isCreditActive;
    }

    creationMap['isActive'] = isActive;
    creationMap['isCreditActive'] = isCreditActive;
    creationMap['creditLimit'] = creditLimit;

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
        child: Scaffold(
          appBar: AppBar(
            title: Text("$wordPrefix Cliente"),
          ),
          bottomNavigationBar: BottomAppBar(
            child: SizedBox(
              height: 60,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                  ),
                ),
              ),
            ),
          ),
          body: Center(
            child: Card(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
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
                              creationMap["phone"] = value?.trim();
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TitleTextField(
                      key: const ValueKey("location_field"),
                      title: "Ubicacion (Ciudad)*",
                      textInputAction: TextInputAction.next,
                      initialValue: widget.client?.location,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "El campo es requerido";
                        }

                        creationMap["location"] = value.trim();
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TitleTextField(
                      key: const ValueKey("address_field"),
                      title: "Direccion",
                      textInputAction: TextInputAction.next,
                      initialValue: widget.client?.address,
                      validator: (value) {
                        creationMap["address"] = value?.trim();
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TitleTextField(
                      key: const ValueKey("email_field"),
                      title: "Correo Electronico (Email)",
                      textInputAction: TextInputAction.next,
                      initialValue: widget.client?.address,
                      validator: (value) {
                        creationMap["email"] = value?.trim();
                        return null;
                      },
                    ),

                    // const SizedBox(height: 12),

                    // TitleTextField(
                    //   key: const ValueKey("credit_field"),
                    //   title: "Limite de Credito(C\$)*",
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [IntegerThousandsFormatter()],
                    //   initialValue: (widget.client?.creditLimit ?? 0).toString(),
                    //   validator: (value) {
                    //     final formattedValue = value?.replaceAll(RegExp(r'[^0-9]'), "");
                    //     if (formattedValue == null || formattedValue.isEmpty) {
                    //       return "El campo es requerido";
                    //     }

                    //     final number = int.tryParse(formattedValue.trim());

                    //     if (number == null) {
                    //       return "Numero incorrecto";
                    //     }

                    //     creationMap["creditLimit"] = number * 100;
                    //     return null;
                    //   },
                    // ),
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
          ),
        ),
      ),
    );
  }
}
