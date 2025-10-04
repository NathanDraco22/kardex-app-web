import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/unit/unit_model.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/write_unit_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<UnitInDb?> showCreateUnitDialog(BuildContext context, {UnitInDb? unit}) async {
  final cubit = context.read<WriteUnitCubit>();

  return await showDialog<UnitInDb?>(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: const CreateUnitDialog(),
      );
    },
  );
}

class CreateUnitDialog extends StatefulWidget {
  const CreateUnitDialog({super.key});

  @override
  State<CreateUnitDialog> createState() => _CreateUnitDialogState();
}

class _CreateUnitDialogState extends State<CreateUnitDialog> {
  final formKey = GlobalKey<FormState>();

  final creationMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteUnitCubit, WriteUnitState>(
      listener: (context, state) {
        if (state is WriteUnitInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteUnitSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.unit);
        }

        if (state is WriteUnitError) {
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
              title: const Text("Agregar Nueva Unidad"),
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
                      final newUnit = CreateUnit.fromJson(creationMap);
                      context.read<WriteUnitCubit>().createNewUnit(newUnit);
                    }
                  },
                  child: const Text("Agregar Unidad"),
                ),
              ],
              content: Column(
                children: [
                  TitleTextField(
                    title: "Nombre de la Unidad*",
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "El nombre de la unidad es requerido";
                      creationMap['name'] = value.trim();
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
    );
  }
}
