import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shortcuts/shortcuts_cubit.dart';
import 'package:kardex_app_front/cubits/toast/toast_cubit.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';

import 'package:kardex_app_front/widgets/gates/role_permission_gate.dart';
import 'package:toastification/toastification.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'widgets/home_desktop_card.dart';
import 'widgets/home_end_drawer.dart';

part 'mobile/home_mobile.dart';
part 'tablet/home_tablet.dart';
part 'desktop/home_desktop.dart';

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
            resizeToAvoidBottomInset: false,
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

        final hasShortcuts = context.watch<ShortcutsCubit>().state.shortcuts.isNotEmpty;

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
            floatingActionButton: hasShortcuts
                ? FloatingActionButton(
                    heroTag: null,
                    onPressed: () => context.pushNamed(RouteNames.shortcuts),
                    child: const Icon(FluentIcons.bookmark_multiple_24_filled),
                  )
                : null,
            floatingActionButtonLocation: hasShortcuts
                ? (MediaQuery.sizeOf(context).width < maxPhoneScreenWidth
                      ? FloatingActionButtonLocation.endFloat
                      : FloatingActionButtonLocation.centerTop)
                : null,
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

    if (context.isMobile()) {
      return _HomeMobileBody(
        firstName: firstName,
        currentBranch: currentBranch,
      );
    }

    if (context.isTablet()) {
      return _HomeTabletBody(
        firstName: firstName,
        currentBranch: currentBranch,
      );
    }

    return _HomeDesktopBody(
      firstName: firstName,
      currentBranch: currentBranch,
    );
  }
}

class HomeOption {
  final List<Modules> permissions;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final IconData icon;
  final void Function() onTap;

  const HomeOption({
    required this.permissions,
    required this.title,
    this.subtitle,
    this.accentColor,
    required this.icon,
    required this.onTap,
  });
}

List<HomeOption> getHomeOptions(BuildContext context, [BranchInDb? branch]) {
  final currentBranch = branch ?? getIt<AuthCubit>().currentBranch;
  final isCommerce = currentBranch?.isCommerce ?? true;

  return [
    HomeOption(
      permissions: const [Modules.clients],
      title: "Lista de Clientes",
      subtitle: "Directorio, saldos y grupos de clientes",
      accentColor: const Color(0xFF2563EB),
      icon: FluentIcons.contact_card_16_filled,
      onTap: () => context.pushNamed("client-catalog"),
    ),
    HomeOption(
      permissions: const [Modules.suppliers],
      title: "Lista de Proveedores",
      subtitle: "Directorio de proveedores y compras",
      accentColor: const Color(0xFF0D9488),
      icon: FluentIcons.building_multiple_20_filled,
      onTap: () => context.pushNamed("suppliers-catalog"),
    ),
    HomeOption(
      permissions: const [Modules.products],
      title: "Catálogo de Productos",
      subtitle: "Inventario general, precios y categorías",
      accentColor: const Color(0xFF7C3AED),
      icon: FluentIcons.receipt_bag_20_filled,
      onTap: () => context.pushNamed("product-catalog"),
    ),
    if (isCommerce)
      HomeOption(
        permissions: const [Modules.commercial],
        title: "Comercio",
        subtitle: "Terminal de venta, facturación y pedidos",
        accentColor: const Color(0xFF059669),
        icon: FluentIcons.money_calculator_20_filled,
        onTap: () => context.pushNamed("commercial"),
      ),
    if (isCommerce)
      HomeOption(
        permissions: const [Modules.pendingInvoices],
        title: "Cuentas por Cobrar",
        subtitle: "Abonos, facturas pendientes y saldos",
        accentColor: const Color(0xFFD97706),
        icon: FluentIcons.receipt_money_24_filled,
        onTap: () => context.pushNamed("pending-accounts"),
      ),
    HomeOption(
      permissions: const [Modules.inventory],
      title: "Inventario",
      subtitle: "Entradas, salidas, ajustes y traslados",
      accentColor: const Color(0xFFEA580C),
      icon: FluentIcons.box_toolbox_20_filled,
      onTap: () => context.pushNamed("inventory"),
    ),
    HomeOption(
      permissions: const [Modules.expenses],
      title: "Gastos",
      subtitle: "Gastos operativos, proveedores y reportes",
      accentColor: const Color(0xFFE11D48),
      icon: FluentIcons.money_24_regular,
      onTap: () => context.pushNamed("expenses"),
    ),
    HomeOption(
      permissions: const [Modules.finance],
      title: "Finanzas",
      subtitle: "Flujo de caja, resúmenes y reportes",
      accentColor: const Color(0xFF4F46E5),
      icon: FluentIcons.arrow_trending_lines_24_regular,
      onTap: () => context.pushNamed("finances"),
    ),
    HomeOption(
      permissions: const [Modules.advancedTools],
      title: "Herramientas Avanzadas",
      subtitle: "Estadísticas y proyecciones de venta",
      accentColor: const Color(0xFF9333EA),
      icon: Icons.schema_rounded,
      onTap: () => context.pushNamed("advanced-tools"),
    ),
    HomeOption(
      permissions: const [Modules.settings],
      title: "Configuraciones",
      subtitle: "Usuarios, sucursales e integraciones",
      accentColor: const Color(0xFF475569),
      icon: FluentIcons.settings_20_filled,
      onTap: () => context.pushNamed("settings"),
    ),
  ];
}
