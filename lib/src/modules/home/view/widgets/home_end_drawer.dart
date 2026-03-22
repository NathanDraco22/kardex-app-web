import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/repositories/branch_repository.dart';
import 'package:kardex_app_front/src/modules/change_password/change_password_screen.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class HomeEndDrawer extends StatelessWidget {
  const HomeEndDrawer({
    super.key,
    required this.user,
  });

  final UserInDbWithRole user;

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state as Authenticated;

    final allBranches = context.read<BranchesRepository>().branches;
    List<BranchInDb> branches = allBranches.where((element) {
      return user.branches.contains(element.id);
    }).toList();

    final isAdmin = user.role == "Admin";
    if (isAdmin) {
      branches = allBranches;
    }

    final isMultiBranch = authState.servin.isMultiBranch;
    final hasUserMultiBranch = user.branches.length > 1 || isAdmin;

    return SafeArea(
      child: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: .w600,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.password,
                color: Colors.blue,
              ),
              title: const Text(
                "Cambiar Contraseña",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () => showChangePassword(context),
            ),

            const Divider(
              height: 0.0,
              thickness: 2,
            ),

            if (isMultiBranch && hasUserMultiBranch) ...[
              ListTile(
                leading: const Icon(
                  Icons.store,
                  color: Colors.blue,
                ),
                title: const Text("Cambiar Sucursal", style: TextStyle(fontSize: 16)),
                onTap: () async {
                  final filteredBranches = branches.where((element) {
                    return element.id != BranchesTool.getCurrentBranchId();
                  }).toList();
                  final res = await showBranchSelectionDialog(context, filteredBranches);
                  if (res == null) return;
                  if (!context.mounted) return;
                  context.read<AuthCubit>().changeBranch(res.id);
                },
              ),

              const Divider(
                height: 0.0,
                thickness: 2,
              ),
            ],

            if (isAdmin && isMultiBranch)
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.blue,
                ),
                title: const Text("Ir a Panel Administrativo", style: TextStyle(fontSize: 16)),
                onTap: () async {
                  context.goNamed("admin-panel");
                },
              ),

            const Spacer(),
            ListTile(
              tileColor: Colors.red.shade100,
              leading: Icon(Icons.exit_to_app, color: Colors.red.shade700),

              title: Text(
                "Cerrar Sesión",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
              ),
              onTap: () async {
                final res = await DialogManager.confirmActionDialog(context, "Deseas cerrar sesión?");
                if (res != true) return;
                if (!context.mounted) return;
                LoadingDialogManager.showLoadingDialog(context);
                await context.read<AuthCubit>().logout();
                if (!context.mounted) return;
                LoadingDialogManager.closeLoadingDialog(context);
                context.goNamed("login");
              },
            ),
          ],
        ),
      ),
    );
  }
}
