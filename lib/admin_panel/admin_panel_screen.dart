import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/admin_panel/widgets/custom_7_charts.dart';
import 'package:kardex_app_front/admin_panel/widgets/panel_drawer.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/branch_repository.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/branch_selection_dialog.dart';

import 'widgets/title_amount.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (authState is! Authenticated) {
      Future(() {
        if (!context.mounted) return;
        context.goNamed("login");
      });
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final user = authState.session.user;
    return Scaffold(
      endDrawer: PanelEndDrawer(user: user),
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
        actions: const [
          AvatarButton(),
          SizedBox(width: 12),
        ],
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (authState is! Authenticated) {
      Future(() {
        if (!context.mounted) return;
        context.goNamed("login");
      });
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final user = authState.session.user;
    final userName = user.username;
    final firstName = userName.split(" ")[0];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenido/a, $firstName",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      height: 130,
                      padding: const EdgeInsets.all(8),
                      child: const Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TitleAmount(),
                          // TitleAmount(),
                        ],
                      ),
                    ),
                    const Divider(),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        TitleAmount(),
                        Custom7DaysLineChart(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.bar_chart_rounded, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    title: const Text("Reportes"),
                    onTap: () async {},
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.store_rounded, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    title: const Text("Ir a Sucursal"),
                    onTap: () async {
                      final branches = context.read<BranchesRepository>().branches;
                      final res = await showBranchSelectionDialog(
                        context,
                        branches,
                      );

                      if (res == null) return;

                      if (!context.mounted) return;
                      BranchesTool.setCurrentBranch(res);
                      context.go("/home");
                    },
                  ),

                  const Divider(),
                  ListTile(
                    leading: const Icon(FluentIcons.building_multiple_20_filled, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    title: const Text("Catalogo de Proveedores"),
                    onTap: () async {
                      context.pushNamed("suppliers-catalog");
                    },
                  ),

                  const Divider(),
                  ListTile(
                    leading: const Icon(FluentIcons.contact_card_16_filled, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    title: const Text("Catalogo de Clientes"),
                    onTap: () async {
                      context.pushNamed("client-catalog");
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_rounded, color: Colors.blue),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    title: const Text("Configuracion"),
                    onTap: () async {
                      context.pushNamed("settings");
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarButton extends StatefulWidget {
  const AvatarButton({
    super.key,
  });

  @override
  State<AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<AvatarButton> {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    final currentUser = authState.session.user;

    final firstLetter = currentUser.username[0];

    return GestureDetector(
      onTap: () async {
        Scaffold.of(context).openEndDrawer();
      },
      child: CircleAvatar(
        backgroundColor: Colors.amber.shade100,
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
