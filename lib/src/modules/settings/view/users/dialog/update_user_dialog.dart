import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/multi_branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../cubit/read_user_cubit.dart';
import '../cubit/write_user_cubit.dart';

Future<void> showUpdateUserDialog(BuildContext context, UserInDbWithRole user) async {
  final readCubit = context.read<ReadUserCubit>();
  final writeCubit = context.read<WriteUserCubit>();
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: readCubit),
          BlocProvider.value(value: writeCubit),
        ],
        child: UpdateUserDialog(user: user),
      );
    },
  );
}

class UpdateUserDialog extends StatefulWidget {
  const UpdateUserDialog({super.key, required this.user});

  final UserInDbWithRole user;

  @override
  State<UpdateUserDialog> createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  String username = "";
  String selectedUserId = "";

  bool isActive = true;

  late String selectedRole;

  List<String> selectedBranchIds = [];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    isActive = widget.user.isActive;
    username = widget.user.username;
    selectedRole = widget.user.role;
    selectedBranchIds = widget.user.branches;
    selectedUserId = widget.user.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state as Authenticated;
    final isMultiBranch = authState.servin.isMultiBranch;
    final loggedUser = authState.session.user;
    final writeCubit = context.read<WriteUserCubit>();
    final readCubit = context.read<ReadUserCubit>();
    final readState = readCubit.state as ReadUserSuccess;
    final roles = readState.roles;
    final allBranches = readState.branches;

    return BlocListener(
      bloc: writeCubit,
      listener: (context, state) async {
        if (state is WriteUserInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is DeleteUserSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          readCubit.removeUser(state.user);
          await DialogManager.showInfoDialog(context, "Usuario ${state.user.username} eliminado");
          if (!context.mounted) return;
          context.pop(state.user);
        }

        if (state is UpdateUserSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);

          final currentRol = readState.roles.firstWhere((element) => element.id == selectedRole);

          final updatedUser = UserInDbWithRole(
            id: state.user.id,
            username: username,
            password: "password",
            role: selectedRole,
            createdAt: state.user.createdAt,
            isActive: isActive,
            branches: state.user.branches,
            userRole: UserRole(
              name: currentRol.name,
              access: currentRol.access,
            ),
          );
          readCubit.markUserUpdated(updatedUser);
          await DialogManager.showInfoDialog(context, "Usuario actualizado");
          if (!context.mounted) return;
          context.pop(state.user);
        }

        if (state is WriteUserError) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showErrorDialog(context, state.error);
        }
      },
      child: AlertDialog(
        title: const Text("Actualizar Usuario"),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TitleTextField(
                  title: "Nombre Completo",
                  initialValue: username,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  onChanged: (value) {
                    username = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Campo requerido";
                    if (value.length < 3) return "El usuario debe tener al menos 3 caracteres";
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Rol"),
                    const SizedBox(height: 6),
                    DropdownMenuFormField<String>(
                      width: 300,
                      initialSelection: selectedRole,
                      dropdownMenuEntries: [
                        ...roles.map(
                          (element) => DropdownMenuEntry(
                            label: element.name,
                            value: element.id,
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        selectedRole = value!;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const SizedBox(height: 12),

                Builder(
                  builder: (context) {
                    if (!isMultiBranch) {
                      selectedBranchIds = [BranchesTool.getCurrentBranchId()];
                      return const SizedBox.shrink();
                    }
                    return Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final selectedBranches = await showMultiBranchSelectionDialog(
                              context,
                              allBranches: allBranches,
                              initialSelectedBranchIds: selectedBranchIds,
                            );
                            if (!context.mounted) return;
                            if (selectedBranches == null) return;
                            selectedBranchIds = selectedBranches;
                            setState(() {});
                          },
                          child: Text("Seleccionar Ramas/Sucursales (${selectedBranchIds.length})"),
                        ),
                      ],
                    );
                  },
                ),

                if (selectedUserId != loggedUser.id)
                  SwitchListTile(
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                    title: const Text("Activo"),
                  ),

                if (selectedUserId != loggedUser.id)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("Eliminar Usuario", style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      final result = await DialogManager.slideToConfirmDeleteActionDialog(
                        context,
                        "¿Está seguro de eliminar el usuario ${widget.user.username}?",
                      );
                      if (!context.mounted) return;
                      if (result == true) {
                        writeCubit.deleteUser(widget.user.id);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
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

              final updateUser = UpdateUser(
                username: username,
                isActive: isActive,
                role: selectedRole,
                branches: selectedBranchIds,
              );

              writeCubit.updateUser(widget.user.id, updateUser);
            },
            child: const Text("Actualizar Usuario"),
          ),
        ],
      ),
    );
  }
}
