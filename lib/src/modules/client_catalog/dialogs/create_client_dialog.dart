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

class WriteClientDialog extends StatelessWidget {
  const WriteClientDialog({
    super.key,
    this.client,
  });

  final ClientInDb? client;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final formKey = GlobalKey<FormState>();

    final creationMap = {};

    final wordPrefix = client == null ? "Agregar" : "Actualizar";

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
          title: Text("$wordPrefix Nuevo Cliente"),
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

                if (client == null) {
                  final createClient = CreateClient.fromJson(creationMap);
                  writeCubit.createNewClient(createClient);
                } else {
                  final updateClient = UpdateClient.fromJson(creationMap);
                  writeCubit.updateClient(client!.id, updateClient);
                }
              },
              child: Text("$wordPrefix Client"),
            ),
          ],
          content: SizedBox(
            width: 400,
            height: screenSize.height * 0.7,
            child: Column(
              children: [
                TitleTextField(
                  title: "Nombre",
                  initialValue: client?.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "El campo es requerido";
                    }
                    creationMap["name"] = value;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const Flexible(child: Placeholder()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
