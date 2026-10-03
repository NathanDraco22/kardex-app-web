import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_list/cubit/client_write_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:latlong2/latlong.dart';

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
  int defaultPriceLevel = 1;

  @override
  void initState() {
    if (widget.client != null) {
      creationMap['coordinates'] = widget.client!.coordinates;
      creationMap['personalReferences'] = List<PersonalReference>.from(widget.client!.personalReferences);
      creditLimit = widget.client!.creditLimit;
      defaultPriceLevel = widget.client!.defaultPriceLevel;
    } else {
      creationMap['personalReferences'] = <PersonalReference>[];
      defaultPriceLevel = 1;
    }
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
    creationMap['defaultPriceLevel'] = defaultPriceLevel;

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
                      initialValue: widget.client?.email,
                      validator: (value) {
                        creationMap["email"] = value?.trim();
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Grupo de Clientes",
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 6),
                              Builder(
                                builder: (context) {
                                  final groupsRepo = context.read<ClientGroupsRepository>();
                                  ClientGroupInDb? currentGroup;
                                  if (widget.client != null) {
                                    for (var g in groupsRepo.clientGroups) {
                                      if (g.name == widget.client!.group) {
                                        currentGroup = g;
                                        break;
                                      }
                                    }
                                  }

                                  return CustomAutocompleteTextfield<ClientGroupInDb>(
                                    initValue: currentGroup,
                                    onClose: (value) => creationMap['group'] = value.name,
                                    onFieldSubmitted: (value) {
                                      FocusScope.of(context).nextFocus();
                                    },
                                    onSearch: (value) {
                                      return groupsRepo.searchClientGroupByKeywordLocal(value);
                                    },
                                    suggestionBuilder: (value, close) {
                                      return ListView.builder(
                                        itemCount: value.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) => ListTile(
                                          title: Text(value[index].name),
                                          onTap: () {
                                            creationMap['group'] = value[index].name;
                                            close(value[index]);
                                            FocusScope.of(context).nextFocus();
                                          },
                                        ),
                                      );
                                    },
                                    titleBuilder: (value) => value.name,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SecondaryMenuButton(
                          label: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Coordenadas"),
                              Builder(
                                builder: (context) {
                                  final coordinates = creationMap['coordinates'] as Coordinates?;
                                  String text = "-----";

                                  if (coordinates != null) {
                                    text = "Ver coordenadas";
                                  }
                                  return Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          icon: Builder(
                            builder: (context) {
                              final coordinates = creationMap['coordinates'] as Coordinates?;
                              if (coordinates != null) {
                                return const Icon(Icons.location_on);
                              }
                              return const Icon(Icons.location_off);
                            },
                          ),
                          onPressed: () async {
                            LatLng initCoords = const LatLng(12.130717, -86.253267);
                            if (creationMap['coordinates'] != null) {
                              final coords = creationMap['coordinates'] as Coordinates;
                              initCoords = LatLng(coords.latitude, coords.longitude);
                            }

                            final result = await showMapBottomModal(
                              context,
                              title: "Coordenadas",
                              initialCenter: initCoords,
                              markers: [
                                if (creationMap['coordinates'] != null) ...[
                                  MarkerData(
                                    title: widget.client?.name ?? "Sin Nombre",
                                    coordinates: creationMap['coordinates'] as Coordinates,
                                  ),
                                ],
                              ],
                            );
                            if (result != null) {
                              setState(() {
                                creationMap['coordinates'] = result;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            final refs = creationMap['personalReferences'] as List<PersonalReference>? ?? [];
                            return OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () async {
                                final updatedRefs = await showClientPersonalReferenceEditor(
                                  context,
                                  refs,
                                );

                                if (updatedRefs != null) {
                                  setState(() {
                                    creationMap['personalReferences'] = updatedRefs;
                                  });
                                }
                              },
                              icon: const Icon(Icons.group),
                              label: Text("Referencias Personales (${refs.length})"),
                            );
                          },
                        ),
                      ],
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

                    const SizedBox(height: 12),
                    TitleTextField(
                      key: const ValueKey("creditLimit_field"),
                      title: "Limite de Credito",
                      initialValue: NumberFormatter.convertFromCentsToUnitsCurrency(creditLimit),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          creditLimit = 0;
                        } else {
                          final parsed = double.tryParse(value.replaceAll(',', ''));
                          if (parsed != null) {
                            creditLimit = (parsed * 100).toInt();
                          }
                        }
                        creationMap["creditLimit"] = creditLimit;
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Nivel de precio predeterminado',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: defaultPriceLevel,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Precio 1')),
                        DropdownMenuItem(value: 2, child: Text('Precio 2')),
                        DropdownMenuItem(value: 3, child: Text('Precio 3')),
                        DropdownMenuItem(value: 4, child: Text('Precio 4')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            defaultPriceLevel = value;
                            creationMap['defaultPriceLevel'] = value;
                          });
                        }
                      },
                    ),

                    if (currentClient != null) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SecondaryMenuButton(
                            foregroundColor: Colors.red,
                            borderColor: Colors.red.shade200,
                            onPressed: () async {
                              final res = await DialogManager.slideToConfirmDeleteActionDialog(
                                context,
                                "Deseas eliminar el cliente ${currentClient.name}?",
                              );
                              if (!res) return;
                              writeCubit.deleteClient(currentClient.id);
                            },
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
