import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/models/common/coordinates.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/cubit/read_branch_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/cubit/write_branch_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/modals/map_bottom_modal.dart';
import 'package:kardex_app_front/widgets/pick_img_widget.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';
import 'package:latlong2/latlong.dart';

Future<BranchInDb?> showCreateBranchPriceDialog(
  BuildContext context, {
  BranchInDb? branch,
}) async {
  final writeCubit = context.read<WriteBranchCubit>();
  final readCubit = context.read<ReadBranchCubit>();

  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: writeCubit),
            BlocProvider.value(value: readCubit),
          ],
          child: CreateProductPriceDialog(
            branch: branch,
          ),
        );
      },
    ),
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

  XFile? _imageFile;

  final creationMap = <String, dynamic>{};
  @override
  void initState() {
    super.initState();
    creationMap['coordinates'] = widget.branch?.coordinates;
  }

  @override
  Widget build(BuildContext context) {
    final currenBranch = widget.branch;

    ImageProvider? currentImageProvider;
    if (currenBranch?.image != null && currenBranch!.image!.isNotEmpty) {
      currentImageProvider = MemoryImage(currenBranch.image!);
    }
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
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Rama/Sucursal",
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      PickImgWidget(
                        initialImage: currentImageProvider,
                        onImageSelected: (image) {
                          _imageFile = image;
                        },
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            TitleTextField(
                              title: "Nombre de Rama/Sucursal*",
                              textCapitalization: TextCapitalization.words,
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
                              title: "Numero Ruc/Cedula",
                              initialValue: currenBranch?.idCard,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null) return null;
                                creationMap['idCard'] = value.trim();
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TitleTextField(
                              title: "Direccion",
                              initialValue: currenBranch?.address,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value == null) return null;
                                creationMap['address'] = value.trim();
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TitleTextField(
                                    title: "Telefono",
                                    initialValue: currenBranch?.phone,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.sentences,
                                    validator: (value) {
                                      if (value == null) return null;
                                      creationMap['phone'] = value.trim();
                                      return null;
                                    },
                                  ),
                                ),
                                TextButton.icon(
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
                                            title: currenBranch?.name ?? "Sin Nombre",
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

                            TitleTextField(
                              title: "Correo Electronico",
                              initialValue: currenBranch?.email,
                              textInputAction: TextInputAction.next,

                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value == null) return null;
                                creationMap['email'] = value.trim();
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TitleTextField(
                              title: "Descripción de Rama/Sucursal",
                              initialValue: currenBranch?.description,
                              textInputAction: TextInputAction.next,

                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value == null) return null;
                                creationMap['description'] = value.trim();
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
              ),
            ),
          ),

          bottomNavigationBar: BottomAppBar(
            child: SizedBox(
              height: 50,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        child: const Text("Cancelar"),
                        onPressed: () => context.pop(),
                      ),

                      ElevatedButton(
                        child: const Text("Guardar"),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          if (widget.branch == null) {
                            final res = await DialogManager.slideToConfirmActionDialog(
                              context,
                              "Deseas Crear la Rama/Sucursal?",
                            );

                            if (!res) return;

                            if (!context.mounted) return;

                            final createBranch = CreateBranch.fromJson(creationMap);
                            context.read<WriteBranchCubit>().createNewBranch(createBranch, _imageFile);
                            return;
                          }

                          final updateBranch = UpdateBranch.fromJson(creationMap);

                          context.read<WriteBranchCubit>().updateBranch(
                            widget.branch!.id,
                            updateBranch,
                            _imageFile,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
