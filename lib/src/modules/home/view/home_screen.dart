import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/toast/toast_cubit.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/src/domain/models/user_role/modules.dart';
import 'package:kardex_app_front/widgets/gates/role_permission_gate.dart';
import 'package:toastification/toastification.dart';

import 'widgets/home_card_option.dart';
import 'widgets/home_end_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authState is AuthError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  getIt<AuthCubit>().logout();
                },
              ),
              title: const Text("Error"),
            ),
            body: Center(
              child: Text(authState.message),
            ),
          );
        }

        if (authState is! Authenticated) {
          Future(() {
            if (!context.mounted) return;
            context.goNamed("login");
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authState.session.user;

        return BlocListener<ToastCubit, ToastState>(
          listener: (context, state) {
            if (state is! ToastMessage) {
              return;
            }
            toastification.show(
              context: context,
              type: ToastificationType.warning,
              title: Text(state.message),
              backgroundColor: Colors.amber.shade100,
            );
          },
          child: Scaffold(
            endDrawer: HomeEndDrawer(user: user),
            appBar: AppBar(
              title: const Text("Neptuno App"),
              actions: [
                const AvatarButton(),
                const SizedBox(width: 12),
              ],
            ),
            backgroundColor: Colors.white,
            body: const _Body(),
          ),
        );
      },
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ToastCubit>().hasNearExpiration(
      getIt<AuthCubit>().currentBranchId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
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

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
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
    final currentBranch = getIt<AuthCubit>().currentBranch;
    return Center(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        children: [
          if (currentBranch != null) ...[
            Text(
              currentBranch.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              currentBranch.address,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 4),
          Text(
            "Bienvenido/a, $firstName",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            "Elige una opcion",
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: buildHomeOptions(context).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

Iterable<Widget> buildHomeOptions(BuildContext context) sync* {
  final listOptions = [
    (
      [Modules.clients],
      "Lista de Clientes",
      FluentIcons.contact_card_16_filled,
      () => context.pushNamed("client-catalog"),
    ),
    (
      [Modules.products],
      "Catalogo de Productos",
      FluentIcons.receipt_bag_20_filled,
      () => context.pushNamed("product-catalog"),
    ),
    (
      [Modules.commercial],
      "Comercio",
      FluentIcons.money_calculator_20_filled,
      () => context.pushNamed("commercial"),
    ),
    (
      [Modules.pendingInvoices],
      "Cuentas por Cobrar",
      FluentIcons.receipt_money_24_filled,
      () => context.pushNamed("pending-accounts"),
    ),
    (
      [Modules.inventory],
      "Inventario",
      FluentIcons.box_toolbox_20_filled,
      () => context.pushNamed("inventory"),
    ),
    (
      [Modules.expenses],
      "Gastos",
      FluentIcons.money_24_regular,
      () => context.pushNamed("expenses"),
    ),
    (
      [Modules.finance],
      "Finanzas",
      FluentIcons.arrow_trending_lines_24_regular,
      () => context.pushNamed("finances"),
    ),
    (
      [Modules.settings],
      "Configuraciones",
      FluentIcons.settings_20_filled,
      () => context.pushNamed("settings"),
    ),
  ];

  for (final (permissions, title, icon, onTap) in listOptions) {
    yield RolePermissionGate(
      width: 300,
      height: 120,
      permissions: permissions,
      child: HomeOptionCard(title: title, icon: icon, onTap: onTap),
    );
  }
}
