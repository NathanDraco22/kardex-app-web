import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/modules/change_password/change_password_screen.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class PanelEndDrawer extends StatelessWidget {
  const PanelEndDrawer({
    super.key,
    required this.user,
  });

  final UserInDbWithRole user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.password),
              title: const Text("Cambiar Contraseña"),
              onTap: () => showChangePassword(context),
            ),

            const Divider(),

            const Spacer(),
            ListTile(
              tileColor: Colors.red.shade100,
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.red.shade700,
              ),

              title: Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: Colors.red.shade700,
                ),
              ),
              onTap: () async {
                final res = await DialogManager.confirmActionDialog(
                  context,
                  "Deseas cerrar sesión?",
                );
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
