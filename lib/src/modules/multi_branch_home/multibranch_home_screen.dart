import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/branch_selection_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

class MultibranchHomeScreen extends StatelessWidget {
  const MultibranchHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MultibranchBody();
  }
}

class _MultibranchBody extends StatefulWidget {
  const _MultibranchBody();

  @override
  State<_MultibranchBody> createState() => _MultibranchBodyState();
}

class _MultibranchBodyState extends State<_MultibranchBody> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      builder: (context, authState) {
        if (authState is AuthLoading || authState is AuthInitial) {
          return const _StatusScaffold(
            child: CircularProgressIndicator(),
          );
        }

        if (authState is AuthError) {
          return _ErrorView(message: authState.message);
        }

        if (authState is AuthInactive) {
          _redirectTo(context, "activation");
          return const _StatusScaffold(
            child: CircularProgressIndicator(),
          );
        }

        if (authState is! Authenticated) {
          _redirectTo(context, "login");
          return const _StatusScaffold(
            child: CircularProgressIndicator(),
          );
        }

        return _buildAuthenticated(context, authState);
      },
    );
  }

  void _redirectTo(BuildContext context, String routeName) {
    Future(() {
      if (!context.mounted) return;
      context.goNamed(routeName);
    });
  }

  Widget _buildAuthenticated(BuildContext context, Authenticated authState) {
    final user = authState.session.user;
    final appSettings = context.watch<AppSettingsCubit>();
    final isAdmin = user.role == "Admin" || user.username.toLowerCase() == "root";
    final branches = isAdmin
        ? authState.branches
        : authState.branches.where((branch) => user.branches.contains(branch.id)).toList();
    final firstName = user.username.trim().split(" ").first;
    final companyName = authState.servin.name.trim().isNotEmpty ? authState.servin.name.trim() : "Neptuno";

    return Scaffold(
      body: _PageBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 20,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopBar(
                          user: user,
                          onLogout: _logout,
                        ),
                        const SizedBox(height: 22),
                        _HeroCard(
                          companyName: companyName,
                          firstName: firstName,
                          role: user.role,
                          companyLogoUrl: appSettings.companyLogoUrl,
                          branchCount: branches.length,
                          isWide: isWide,
                        ),
                        const SizedBox(height: 20),
                        _WorkspaceActions(
                          isWide: isWide,
                          showAdmin: isAdmin,
                          branchCount: branches.length,
                          onAdmin: () => context.goNamed("admin-panel"),
                          onBranches: () => _openBranches(branches),
                        ),
                        const SizedBox(height: 28),
                        _BranchesSection(
                          branches: branches,
                          currentBranchId: authState.branch.id,
                          onSelect: _selectBranch,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openBranches(List<BranchInDb> branches) async {
    if (branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes sucursales asignadas."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selected = await showBranchSelectionDialog(
      context,
      branches,
      currentBranchId: getIt<AuthCubit>().currentBranchId,
    );

    if (selected == null || !mounted) return;
    _selectBranch(selected);
  }

  void _selectBranch(BranchInDb branch) {
    if (branch.id != getIt<AuthCubit>().currentBranchId) {
      getIt<AuthCubit>().changeBranch(branch.id);
    }
    context.goNamed("home");
  }

  Future<void> _logout() async {
    final confirmed = await DialogManager.confirmActionDialog(
      context,
      "¿Deseas cerrar sesión?",
    );
    if (confirmed != true || !mounted) return;

    await getIt<AuthCubit>().logout();
    if (!mounted) return;
    context.goNamed("login");
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeTokens.surfaceLight,
      child: child,
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PageBackground(
        child: Center(child: child),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _StatusScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppThemeTokens.borderRadiusXl,
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.danger.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: AppThemeTokens.danger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No se pudo cargar la sesión",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await getIt<AuthCubit>().logout();
                          if (!context.mounted) return;
                          context.goNamed("login");
                        },
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text("Ir al login"),
                      ),
                      FilledButton.icon(
                        onPressed: () => getIt<AuthCubit>().checkSession(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("Reintentar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.user,
    required this.onLogout,
  });

  final UserInDbWithRole user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final showSecureChip = MediaQuery.sizeOf(context).width >= 600;

    return Row(
      children: [
        if (showSecureChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppThemeTokens.borderRadiusFull,
              border: Border.all(color: AppThemeTokens.borderLight),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 15,
                  color: AppThemeTokens.teal,
                ),
                SizedBox(width: 6),
                Text(
                  "Acceso seguro",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        _UserChip(user: user),
        const SizedBox(width: 8),
        IconButton(
          tooltip: "Cerrar sesión",
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red.shade700,
            side: const BorderSide(color: AppThemeTokens.borderLight),
          ),
        ),
      ],
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.user});

  final UserInDbWithRole user;

  @override
  Widget build(BuildContext context) {
    final initial = user.username.trim().isNotEmpty ? user.username.trim()[0].toUpperCase() : "?";

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppThemeTokens.indigo.withValues(alpha: 0.08),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.indigo,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  user.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.companyName,
    required this.firstName,
    required this.role,
    required this.companyLogoUrl,
    required this.branchCount,
    required this.isWide,
  });

  final String companyName;
  final String firstName;
  final String role;
  final String? companyLogoUrl;
  final int branchCount;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final logoSize = isWide ? 150.0 : 120.0;

    final logo = Container(
      width: logoSize,
      height: logoSize,
      padding: EdgeInsets.all(isWide ? 18 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: CompanyLogo(
        imageUrl: companyLogoUrl,
        fit: BoxFit.contain,
        fallback: Center(
          child: Icon(
            Icons.business_rounded,
            size: isWide ? 58 : 46,
            color: AppThemeTokens.neutral,
          ),
        ),
        placeholder: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          companyName.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppThemeTokens.neutral,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Bienvenido/a, $firstName",
          style: TextStyle(
            fontSize: isWide ? 32 : 25,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: isWide ? -0.9 : -0.6,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          branchCount == 1
              ? "Tu sesión está activa. Tienes acceso a 1 sucursal."
              : "Tu sesión está activa. Tienes acceso a $branchCount sucursales.",
          style: TextStyle(
            fontSize: 13.5,
            height: 1.4,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const _InfoChip(
              icon: Icons.check_circle_rounded,
              label: "Sesión activa",
              color: AppThemeTokens.teal,
            ),
            _InfoChip(
              icon: Icons.admin_panel_settings_rounded,
              label: role,
              color: AppThemeTokens.indigo,
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(isWide ? 28 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                logo,
                const SizedBox(width: 26),
                Expanded(child: identity),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                logo,
                const SizedBox(height: 18),
                identity,
              ],
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceActions extends StatelessWidget {
  const _WorkspaceActions({
    required this.isWide,
    required this.showAdmin,
    required this.branchCount,
    required this.onAdmin,
    required this.onBranches,
  });

  final bool isWide;
  final bool showAdmin;
  final int branchCount;
  final VoidCallback onAdmin;
  final VoidCallback onBranches;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      if (showAdmin)
        _WorkspaceActionCard(
          title: "Panel Administrativo",
          description: "Consulta ventas, reportes y métricas globales de la empresa.",
          icon: Icons.insights_rounded,
          accent: AppThemeTokens.indigo,
          badge: "Reportes y métricas",
          onTap: onAdmin,
        ),
      _WorkspaceActionCard(
        title: "Sucursales",
        description: "Entra a una sucursal para gestionar inventario, ventas y finanzas.",
        icon: Icons.storefront_rounded,
        accent: AppThemeTokens.teal,
        badge: branchCount == 1 ? "1 sucursal disponible" : "$branchCount sucursales disponibles",
        onTap: onBranches,
      ),
    ];

    if (isWide && cards.length > 1) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          cards[i],
        ],
      ],
    );
  }
}

class _WorkspaceActionCard extends StatefulWidget {
  const _WorkspaceActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final String badge;
  final VoidCallback onTap;

  @override
  State<_WorkspaceActionCard> createState() => _WorkspaceActionCardState();
}

class _WorkspaceActionCardState extends State<_WorkspaceActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.012 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isHovered ? accent.withValues(alpha: 0.30) : AppThemeTokens.borderLight,
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered ? AppThemeTokens.hoverCardShadow(accent: accent) : AppThemeTokens.subtleCardShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(22),
              splashColor: accent.withValues(alpha: 0.08),
              highlightColor: accent.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: accent.withValues(
                          alpha: _isHovered ? 0.14 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accent.withValues(
                            alpha: _isHovered ? 0.28 : 0.14,
                          ),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: _isHovered ? accent : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: AppThemeTokens.borderRadiusFull,
                              border: Border.all(
                                color: AppThemeTokens.borderLight,
                              ),
                            ),
                            child: Text(
                              widget.badge,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      transform: Matrix4.translationValues(
                        _isHovered ? 4.0 : 0.0,
                        0.0,
                        0.0,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: _isHovered ? accent : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchesSection extends StatelessWidget {
  const _BranchesSection({
    required this.branches,
    required this.currentBranchId,
    required this.onSelect,
  });

  final List<BranchInDb> branches;
  final String currentBranchId;
  final ValueChanged<BranchInDb> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              "Tus sucursales",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: AppThemeTokens.borderRadiusFull,
              ),
              child: Text(
                "${branches.length}",
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppThemeTokens.neutral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Selecciona una sucursal para entrar.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),
        if (branches.isEmpty)
          const _EmptyBranches()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              const gap = 14.0;
              final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: branches.map((branch) {
                  return SizedBox(
                    width: cardWidth,
                    child: _BranchCard(
                      branch: branch,
                      isCurrent: branch.id == currentBranchId,
                      onTap: () => onSelect(branch),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}

class _EmptyBranches extends StatelessWidget {
  const _EmptyBranches();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusXl,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 42,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            "No tienes sucursales asignadas",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Contacta al administrador para que te asigne acceso a una sucursal.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatefulWidget {
  const _BranchCard({
    required this.branch,
    required this.isCurrent,
    required this.onTap,
  });

  final BranchInDb branch;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final accent = branch.isCommerce ? const Color(0xFFD97706) : const Color(0xFF475569);
    final borderColor = widget.isCurrent
        ? AppThemeTokens.teal.withValues(alpha: 0.35)
        : _isHovered
        ? accent.withValues(alpha: 0.30)
        : AppThemeTokens.borderLight;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 98,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: widget.isCurrent ? 1.4 : 1.0,
            ),
            boxShadow: _isHovered ? AppThemeTokens.hoverCardShadow(accent: accent) : AppThemeTokens.subtleCardShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: accent.withValues(alpha: 0.08),
              highlightColor: accent.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    BranchAvatar(branch: branch),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  branch.name.trim().isEmpty ? "Sucursal" : branch.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (widget.isCurrent) ...[
                                const SizedBox(width: 6),
                                const _CurrentBadge(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            branch.address.trim().isEmpty ? "Sin dirección registrada" : branch.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _BranchTypeChip(
                            isCommerce: branch.isCommerce,
                            color: accent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: _isHovered ? accent : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchTypeChip extends StatelessWidget {
  const _BranchTypeChip({
    required this.isCommerce,
    required this.color,
  });

  final bool isCommerce;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommerce ? Icons.storefront_rounded : Icons.warehouse_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isCommerce ? "Comercio" : "Almacén",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: AppThemeTokens.borderRadiusFull,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 11,
            color: AppThemeTokens.teal,
          ),
          SizedBox(width: 3),
          Text(
            "Actual",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.teal,
            ),
          ),
        ],
      ),
    );
  }
}
