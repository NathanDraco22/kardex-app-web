import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/admin_panel/widgets/custom_7_charts.dart';
import 'package:kardex_app_front/admin_panel/widgets/panel_drawer.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/global_stock_search_modal.dart';
import 'package:kardex_business/kardex_business.dart';

import 'cubit/read_admin_panel_cubit.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminPanelRepo = context.read<AdminPanelRepository>();
    return BlocProvider(
      create: (context) => ReadAdminPanelCubit(adminPanelRepo)..getCharts(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    if (authState is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (authState is! Authenticated) {
      Future(() {
        if (!context.mounted) return;
        context.goNamed("login");
      });
      return const Center(child: CircularProgressIndicator());
    }
    final user = authState.session.user;
    final appSettings = context.watch<AppSettingsCubit>();
    return Scaffold(
      backgroundColor: AppThemeTokens.surfaceLight,
      endDrawer: PanelEndDrawer(user: user),
      appBar: AppBar(
        title: Row(
          children: [
            if (appSettings.hasCompanyLogo) ...[
              CompanyLogo(
                imageUrl: appSettings.companyLogoUrl,
                height: 26,
                width: 90,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(width: 10),
            ],
            const Expanded(
              child: Text(
                "Panel Administrativo",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
    final authState = getIt<AuthCubit>().state as Authenticated;
    final adminPanelState = context.watch<ReadAdminPanelCubit>().state;

    if (adminPanelState is ReadAdminPanelLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adminPanelState is ReadAdminPanelFailure) {
      return Center(child: Text(adminPanelState.message));
    }

    adminPanelState as ReadAdminPanelSuccess;

    final user = authState.session.user;
    final userName = user.username.trim();
    final firstName = userName.isEmpty ? "usuario" : userName.split(" ").first;
    final branchName = getIt<AuthCubit>().currentBranch?.name;

    final charts = adminPanelState.charts;

    final yesterdayTotal = charts.last7DaysTotals.last;
    final last7DaysTotalAmount = charts.last7DaysTotals.fold(
      0,
      (previousValue, element) => previousValue + element.total,
    );

    final actions = <Widget>[
      AppActionTile(
        icon: Icons.bar_chart_rounded,
        accentColor: AppThemeTokens.indigo,
        title: "Finanzas y reportes",
        subtitle: "Cierre de caja, arqueos y estados financieros.",
        onTap: () => context.pushNamed("admin-reports"),
      ),
      AppActionTile(
        icon: Icons.manage_search_rounded,
        accentColor: AppThemeTokens.info,
        title: "Existencias globales",
        subtitle: "Consulta productos y stock en todas las sucursales.",
        onTap: () => showGlobalStockSearchModal(context),
      ),
      AppActionTile(
        icon: Icons.storefront_rounded,
        accentColor: AppThemeTokens.teal,
        title: "Ir a sucursal",
        subtitle: "Cambia la sucursal activa y entra al home.",
        onTap: () async {
          final branches = context.read<BranchesRepository>().branches;
          final res = await showBranchSelectionDialog(
            context,
            branches,
            currentBranchId: getIt<AuthCubit>().currentBranchId,
          );

          if (res == null || !context.mounted) return;
          getIt<AuthCubit>().changeBranch(res.id);
          context.go("/home");
        },
      ),
      AppActionTile(
        icon: Icons.local_shipping_rounded,
        accentColor: AppThemeTokens.purple,
        title: "Catálogo de proveedores",
        subtitle: "Administra proveedores y condiciones de compra.",
        onTap: () => context.pushNamed("suppliers-catalog"),
      ),
      AppActionTile(
        icon: Icons.people_alt_rounded,
        accentColor: AppThemeTokens.warning,
        title: "Catálogo de clientes",
        subtitle: "Clientes, límites de crédito y balances.",
        onTap: () => context.pushNamed("client-catalog"),
      ),
      AppActionTile(
        icon: Icons.settings_rounded,
        accentColor: AppThemeTokens.neutral,
        title: "Configuración",
        subtitle: "Parámetros, usuarios, roles y periféricos.",
        onTap: () => context.pushNamed("settings"),
      ),
    ];

    return ColoredBox(
      color: AppThemeTokens.surfaceLight,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                _WelcomeHeader(
                  firstName: firstName,
                  branchName: branchName,
                ),
                const SizedBox(height: 22),
                const _SectionHeader(
                  title: "Resumen de ventas",
                  subtitle: "Rendimiento de la empresa",
                ),
                const SizedBox(height: 10),
                _SalesSummary(
                  yesterdayAmount: NumberFormatter.convertToMoneyLike(yesterdayTotal.total),
                  last7DaysAmount: NumberFormatter.convertToMoneyLike(last7DaysTotalAmount),
                ),
                const SizedBox(height: 12),
                _SalesChartCard(
                  data: List.generate(
                    charts.last7DaysTotals.length,
                    (index) => CustomChartData(
                      value: NumberFormatter.convertFromCentsToDouble(charts.last7DaysTotals[index].total),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: "Accesos rápidos",
                  subtitle: "Herramientas de gestión",
                ),
                const SizedBox(height: 10),
                _ActionGrid(tiles: actions),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.firstName,
    required this.branchName,
  });

  final String firstName;
  final String? branchName;

  @override
  Widget build(BuildContext context) {
    final initial = firstName.trim().isEmpty ? "?" : firstName.trim()[0].toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        final showRoleChip = constraints.maxWidth >= 560;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppThemeTokens.borderLight),
            boxShadow: AppThemeTokens.subtleCardShadow(),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppThemeTokens.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppThemeTokens.indigo.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppThemeTokens.indigo,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Bienvenido/a de nuevo",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.neutral,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          size: 14,
                          color: AppThemeTokens.neutral,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            (branchName ?? "").trim().isEmpty ? "Sucursal activa" : branchName!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppThemeTokens.neutral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showRoleChip) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppThemeTokens.indigo.withValues(alpha: 0.06),
                    borderRadius: AppThemeTokens.borderRadiusFull,
                    border: Border.all(
                      color: AppThemeTokens.indigo.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 14,
                        color: AppThemeTokens.indigo,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Panel Administrativo",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppThemeTokens.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppThemeTokens.indigo.withValues(alpha: 0.65),
              borderRadius: AppThemeTokens.borderRadiusFull,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeTokens.neutral,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesSummary extends StatelessWidget {
  const _SalesSummary({
    required this.yesterdayAmount,
    required this.last7DaysAmount,
  });

  final String yesterdayAmount;
  final String last7DaysAmount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;

        final cards = [
          _StatCard(
            title: "Ventas de ayer",
            amount: yesterdayAmount,
            icon: Icons.payments_rounded,
            accent: AppThemeTokens.teal,
          ),
          _StatCard(
            title: "Últimos 7 días",
            amount: last7DaysAmount,
            icon: Icons.calendar_month_rounded,
            accent: AppThemeTokens.indigo,
          ),
        ];

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cards[0],
              const SizedBox(height: 10),
              cards[1],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: accent.withValues(alpha: 0.14)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: AppThemeTokens.neutral,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard({required this.data});

  final List<CustomChartData> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppThemeTokens.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemeTokens.indigo.withValues(alpha: 0.14),
                  ),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppThemeTokens.indigo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Tendencia de ventas",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      "Últimos 7 días",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeTokens.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Custom7DaysLineChart(data: data),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 720;

        if (!useTwoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                tiles[i],
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += 2) {
          final right = i + 1 < tiles.length ? tiles[i + 1] : null;
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: 12),
                  Expanded(child: right ?? const SizedBox.shrink()),
                ],
              ),
            ),
          );
          if (i + 2 < tiles.length) {
            rows.add(const SizedBox(height: 10));
          }
        }

        return Column(children: rows);
      },
    );
  }
}

class AvatarButton extends StatefulWidget {
  const AvatarButton({super.key});

  @override
  State<AvatarButton> createState() => _AvatarButtonState();
}

class _AvatarButtonState extends State<AvatarButton> {
  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    final currentUser = authState.session.user;
    final firstLetter = currentUser.username.trim().isEmpty ? "?" : currentUser.username.trim()[0].toUpperCase();

    return Semantics(
      button: true,
      label: "Abrir menú de usuario",
      child: Tooltip(
        message: currentUser.username,
        child: GestureDetector(
          onTap: () async {
            Scaffold.of(context).openEndDrawer();
          },
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeTokens.borderLight),
              boxShadow: AppThemeTokens.subtleCardShadow(),
            ),
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.indigo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
