import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/shortcuts/shortcuts_cubit.dart';
import 'package:kardex_app_front/src/modules/home/data/home_shortcut_resolver.dart';
import 'package:kardex_app_front/src/modules/home/view/widgets/home_desktop_card.dart';
import 'package:kardex_app_front/src/modules/home/view/widgets/near_expiration_banner.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_business/kardex_business.dart';

class DesktopInitialPanel extends StatelessWidget {
  const DesktopInitialPanel({
    super.key,
    required this.firstName,
    this.currentBranch,
    this.onExploreModules,
  });

  final String firstName;
  final BranchInDb? currentBranch;
  final VoidCallback? onExploreModules;

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BranchHero(branch: currentBranch),
                const SizedBox(height: 20),
                const NearExpirationBanner(isDesktop: true),
                const SizedBox(height: 20),
                Text(
                  "Bienvenido/a, $firstName",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Este es tu punto de partida. Consulta la información de tu sucursal y accede rápido a tus herramientas.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),
                BlocBuilder<ShortcutsCubit, ShortcutsState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final resolver = HomeShortcutResolver.build(context);
                    final shortcuts = state.shortcuts
                        .where((shortcut) => resolver.canAccess(shortcut.routeName))
                        .toList();

                    return _ShortcutsSection(
                      shortcuts: shortcuts,
                      resolver: resolver,
                      onExploreModules: onExploreModules,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _BranchHero extends StatelessWidget {
  const _BranchHero({required this.branch});

  final BranchInDb? branch;

  @override
  Widget build(BuildContext context) {
    final currentBranch = branch;
    if (currentBranch == null) {
      return const _HeroContainer(
        accent: AppThemeTokens.indigo,
        child: Row(
          children: [
            _BranchLogo(branch: null, size: 80),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sucursal no seleccionada",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Selecciona una sucursal para ver su información.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isCommerce = currentBranch.isCommerce;
    final accent = isCommerce ? const Color(0xFFD97706) : const Color(0xFF475569);

    return _HeroContainer(
      accent: accent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680;
          final logo = _BranchLogo(
            branch: currentBranch,
            size: isNarrow ? 72 : 88,
          );
          final identity = _BranchIdentity(
            branch: currentBranch,
            accent: accent,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    logo,
                    const SizedBox(width: 16),
                    Expanded(child: identity),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: accent.withValues(alpha: 0.12)),
                const SizedBox(height: 14),
                _BranchDetails(branch: currentBranch, accent: accent),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              logo,
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(height: 16),
                    Divider(color: accent.withValues(alpha: 0.12)),
                    const SizedBox(height: 14),
                    _BranchDetails(branch: currentBranch, accent: accent),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroContainer extends StatelessWidget {
  const _HeroContainer({
    required this.accent,
    required this.child,
  });

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.07),
            Colors.white,
          ],
        ),
        borderRadius: AppThemeTokens.borderRadiusXl,
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: AppThemeTokens.subtleCardShadow(accent: accent),
      ),
      child: child,
    );
  }
}

class _BranchIdentity extends StatelessWidget {
  const _BranchIdentity({
    required this.branch,
    required this.accent,
  });

  final BranchInDb branch;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          branch.name,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (branch.description.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            branch.description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 10),
        _BranchStatusChip(branch: branch, accent: accent),
      ],
    );
  }
}

class _BranchStatusChip extends StatelessWidget {
  const _BranchStatusChip({
    required this.branch,
    required this.accent,
  });

  final BranchInDb branch;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            branch.isCommerce ? Icons.storefront_rounded : Icons.warehouse_rounded,
            size: 14,
            color: accent,
          ),
          const SizedBox(width: 5),
          Text(
            branch.isCommerce ? "Comercio" : "Almacén",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchDetails extends StatelessWidget {
  const _BranchDetails({
    required this.branch,
    required this.accent,
  });

  final BranchInDb branch;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (branch.address.trim().isNotEmpty)
        _BranchInfoItem(
          icon: Icons.location_on_outlined,
          text: branch.address,
          accent: accent,
          maxWidth: 420,
        ),
      if (branch.phone.trim().isNotEmpty)
        _BranchInfoItem(
          icon: Icons.phone_outlined,
          text: branch.phone,
          accent: accent,
        ),
      if (branch.email.trim().isNotEmpty)
        _BranchInfoItem(
          icon: Icons.email_outlined,
          text: branch.email,
          accent: accent,
        ),
      if (branch.idCard.trim().isNotEmpty)
        _BranchInfoItem(
          icon: Icons.badge_outlined,
          text: branch.idCard,
          accent: accent,
        ),
    ];

    if (items.isEmpty) {
      return Text(
        "Sin datos de contacto registrados.",
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      );
    }

    return Wrap(
      spacing: 24,
      runSpacing: 10,
      children: items,
    );
  }
}

class _BranchInfoItem extends StatelessWidget {
  const _BranchInfoItem({
    required this.icon,
    required this.text,
    required this.accent,
    this.maxWidth = 320,
  });

  final IconData icon;
  final String text;
  final Color accent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchLogo extends StatefulWidget {
  const _BranchLogo({
    required this.branch,
    required this.size,
  });

  final BranchInDb? branch;
  final double size;

  @override
  State<_BranchLogo> createState() => _BranchLogoState();
}

class _BranchLogoState extends State<_BranchLogo> {
  Uint8List? _bytes;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _bytes = widget.branch?.image;
    _resolveLogo();
  }

  @override
  void didUpdateWidget(covariant _BranchLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branch?.id != widget.branch?.id ||
        oldWidget.branch?.imageUrl != widget.branch?.imageUrl ||
        oldWidget.branch?.updatedAt != widget.branch?.updatedAt) {
      _bytes = widget.branch?.image;
      _resolveLogo();
    }
  }

  Future<void> _resolveLogo() async {
    final branch = widget.branch;
    final requestId = ++_requestId;

    if (branch == null) {
      if (mounted && _bytes != null) {
        setState(() => _bytes = null);
      }
      return;
    }

    Uint8List? bytes;
    try {
      bytes = await branch.resolveLogoBytes();
    } catch (_) {
      bytes = branch.image;
    }

    if (!mounted || requestId != _requestId || widget.branch?.id != branch.id) {
      return;
    }

    setState(() => _bytes = bytes ?? branch.image);
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final isCommerce = branch?.isCommerce ?? true;
    final accent = isCommerce ? const Color(0xFFD97706) : const Color(0xFF475569);
    final bytes = _bytes;
    final hasImage = bytes != null && bytes.isNotEmpty;

    return Container(
      width: widget.size,
      height: widget.size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: AppThemeTokens.subtleCardShadow(accent: accent),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            )
          : Icon(
              isCommerce ? Icons.storefront_rounded : Icons.warehouse_rounded,
              color: accent,
              size: widget.size * 0.42,
            ),
    );
  }
}

class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection({
    required this.shortcuts,
    required this.resolver,
    required this.onExploreModules,
  });

  final List<Shortcut> shortcuts;
  final HomeShortcutResolver resolver;
  final VoidCallback? onExploreModules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Accesos directos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemeTokens.indigo.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${shortcuts.length}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppThemeTokens.indigo,
                    ),
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.shortcuts),
              icon: const Icon(Icons.tune_rounded, size: 17),
              label: const Text("Gestionar"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeTokens.indigo,
                side: BorderSide(
                  color: AppThemeTokens.indigo.withValues(alpha: 0.30),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (shortcuts.isEmpty)
          _EmptyShortcuts(
            hasModules: onExploreModules != null,
            onExploreModules: onExploreModules,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shortcuts.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 112,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              return Builder(
                builder: (itemContext) {
                  return GestureDetector(
                    onLongPress: () => _showRemoveMenu(itemContext, shortcut.routeName),
                    onSecondaryTap: () => _showRemoveMenu(itemContext, shortcut.routeName),
                    child: HomeDesktopOptionCard(
                      title: resolver.titleFor(shortcut.routeName),
                      subtitle: "Acceso directo",
                      icon: resolver.iconFor(shortcut.routeName),
                      accentColor: resolver.colorFor(shortcut.routeName),
                      onTap: () => context.pushNamed(shortcut.routeName),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Future<void> _showRemoveMenu(BuildContext context, String routeName) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height / 2,
        offset.dx + size.width,
        offset.dy + size.height / 2,
      ),
      items: const [
        PopupMenuItem<String>(
          value: 'remove',
          child: Text('Remover de accesos directos'),
        ),
      ],
    );

    if (result == 'remove' && context.mounted) {
      context.read<ShortcutsCubit>().removeShortcut(routeName);
    }
  }
}

class _EmptyShortcuts extends StatelessWidget {
  const _EmptyShortcuts({
    required this.hasModules,
    required this.onExploreModules,
  });

  final bool hasModules;
  final VoidCallback? onExploreModules;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bookmarks_rounded,
            size: 42,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            "Aún no tienes accesos directos",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasModules
                ? "Mantén presionado un submódulo del menú para agregarlo aquí."
                : "No tienes módulos asignados en esta sucursal.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          if (hasModules && onExploreModules != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onExploreModules,
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text("Explorar módulos"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeTokens.indigo,
                side: BorderSide(
                  color: AppThemeTokens.indigo.withValues(alpha: 0.30),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
