import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/toast/toast_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:toastification/toastification.dart';

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
    return BlocBuilder<AuthCubit, AuthState>(bloc: getIt<AuthCubit>(),
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
    final accessManager = AccessManager();
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
            spacing: 24,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              if (accessManager.hasAccessTo(user, Modules.clients))
                HomeOptionCard(
                  title: "Lista de Clientes",
                  icon: FluentIcons.contact_card_16_filled,
                  onTap: () {
                    context.pushNamed("client-catalog");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.suppliers))
                HomeOptionCard(
                  title: "Lista de Proveedores",
                  icon: FluentIcons.building_multiple_20_filled,
                  onTap: () {
                    context.pushNamed("suppliers-catalog");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.products))
                HomeOptionCard(
                  title: "Catalogo de Productos",
                  icon: FluentIcons.receipt_bag_20_filled,
                  onTap: () {
                    context.pushNamed("product-catalog");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.commercial))
                HomeOptionCard(
                  title: "Comercio",
                  icon: FluentIcons.money_calculator_20_filled,
                  onTap: () {
                    context.pushNamed("commercial");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.commercial))
                HomeOptionCard(
                  title: "Cuentas por Cobrar",
                  icon: FluentIcons.receipt_money_24_filled,
                  onTap: () {
                    context.pushNamed("pending-accounts");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.inventory))
                HomeOptionCard(
                  title: "Inventario",
                  icon: FluentIcons.box_toolbox_20_filled,
                  onTap: () {
                    context.pushNamed("inventory");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.finance))
                HomeOptionCard(
                  title: "Finanzas",
                  icon: FluentIcons.arrow_trending_lines_24_regular,
                  onTap: () {
                    context.pushNamed("finances");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.advancedTools))
                HomeOptionCard(
                  title: "Herramientas Avanzadas",
                  icon: Icons.schema_rounded,
                  onTap: () {
                    context.pushNamed("advanced-tools");
                  },
                ),

              if (accessManager.hasAccessTo(user, Modules.settings))
                HomeOptionCard(
                  title: "Configuraciones",
                  icon: FluentIcons.settings_20_filled,
                  onTap: () {
                    context.pushNamed("settings");
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class HomeOptionCard extends StatelessWidget {
  const HomeOptionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        height: 120,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
            ),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
