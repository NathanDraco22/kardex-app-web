import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/models/user_role/user_role_model.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/multi_branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../cubit/read_user_cubit.dart';
import '../cubit/write_user_cubit.dart';

Future<void> showCreateUserDialog(BuildContext context) async {
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
        child: const CreateUserDialog(),
      );
    },
  );
}

class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  String username = "";
  String password = "";
  String fullName = "";

  UserRoleInDb? selectedRole;

  List<String> selectedBranchIds = [];

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state as Authenticated;
    final isMultiBranch = authState.servin.isMultiBranch;

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

        if (state is WriteUserSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          final newUser = UserInDbWithRole(
            id: state.user.id,
            username: username,
            password: "password",
            role: selectedRole!.id,
            createdAt: state.user.createdAt,
            branches: state.user.branches,
            userRole: UserRole(
              name: selectedRole!.name,
              access: selectedRole!.access,
            ),
          );
          readCubit.putUserFirst(newUser);
          await DialogManager.showInfoDialog(context, "Usuario creado");
          if (!context.mounted) return;
          context.pop(state.user);
        }

        if (state is DeleteUserSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          readCubit.removeUser(state.user);
          await DialogManager.showInfoDialog(context, "Usuario eliminado");
          if (!context.mounted) return;
          context.pop(state.user);
        }

        if (state is UpdateUserSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          final updatedUser = UserInDbWithRole(
            id: state.user.id,
            username: username,
            password: password,
            role: selectedRole!.id,
            createdAt: state.user.createdAt,
            branches: state.user.branches,
            userRole: UserRole(
              name: selectedRole!.name,
              access: selectedRole!.access,
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
        title: const Text("Crear Usuario"),
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
                const SizedBox(height: 8),
                TitleTextField(
                  title: "Contraseña",
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),

                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Campo requerido";
                    if (value.length < 3) return "La contraseña debe tener al menos 3 caracteres";

                    return null;
                  },
                ),

                const SizedBox(height: 8),
                TitleTextField(
                  title: "Confirmar Contraseña",
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),

                  validator: (value) {
                    if (value == null || value.isEmpty) return "Campo requerido";
                    if (value != password) return "Las contraseñas no coinciden";
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Rol"),
                    const SizedBox(height: 6),
                    DropdownMenuFormField<UserRoleInDb>(
                      width: 300,
                      dropdownMenuEntries: [
                        ...roles.map(
                          (element) => DropdownMenuEntry(
                            label: element.name,
                            value: element,
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        selectedRole = value as UserRoleInDb;
                      },
                    ),
                  ],
                ),

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
              if (selectedRole == null) return;
              if (selectedBranchIds.isEmpty) {
                DialogManager.showErrorDialog(context, "Debe seleccionar al menos una rama/sucursal");
                return;
              }

              final createUser = CreateUser(
                username: username,
                password: password,
                role: selectedRole!.id,
                branches: selectedBranchIds,
              );

              writeCubit.createNewUser(createUser);
            },
            child: const Text("Crear Usuario"),
          ),
        ],
      ),
    );
  }
}
