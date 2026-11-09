import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/shortcuts/shortcuts_cubit.dart';
import 'package:kardex_app_front/src/modules/home/data/home_modules_registry.dart';
import 'package:kardex_app_front/src/modules/home/data/home_shortcut_resolver.dart';
import 'package:kardex_business/kardex_business.dart';

class DesktopModuleSidebar extends StatelessWidget {
  final List<HomeModuleCategory> categories;
  final HomeModuleId? selectedModuleId;
  final ValueChanged<HomeModuleId?> onSelect;
  final BranchInDb? currentBranch;

  const DesktopModuleSidebar({
    super.key,
    required this.categories,
    required this.selectedModuleId,
    required this.onSelect,
    this.currentBranch,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsCubit>();
    final shortcuts = context.watch<ShortcutsCubit>().state.shortcuts;
    final shortcutResolver = HomeShortcutResolver.build(context);
    final shortcutCount = shortcuts.where((shortcut) => shortcutResolver.canAccess(shortcut.routeName)).length;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentBranch != null) _buildBranchHeader(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: _InitialSidebarItem(
              isSelected: selectedModuleId == null,
              shortcutCount: shortcutCount,
              onTap: () => onSelect(null),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "MÓDULOS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${categories.length}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Sin módulos asignados",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category.id == selectedModuleId;
                      return _SidebarItem(
                        category: category,
                        isSelected: isSelected,
                        onTap: () => onSelect(category.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchHeader(BuildContext context) {
    final branch = currentBranch!;
    final isCommerce = branch.isCommerce;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCommerce
            ? Colors.amber.shade50.withValues(alpha: 0.5)
            : Colors.blueGrey.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCommerce ? Colors.amber.shade200 : Colors.blueGrey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCommerce ? Colors.amber.shade100 : Colors.blueGrey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCommerce ? FluentIcons.building_shop_24_filled : Icons.warehouse_rounded,
              color: isCommerce ? Colors.amber.shade900 : Colors.blueGrey.shade800,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        branch.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  branch.address,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final HomeModuleCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final isSelected = widget.isSelected;
    final accent = category.accentColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.12)
              : _isHovered
              ? Colors.grey.shade100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent.withValues(alpha: 0.35) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? accent : accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      category.icon,
                      color: isSelected ? Colors.white : accent,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? accent : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${category.submodules.length}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    )
                  else if (_isHovered)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.grey.shade400,
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

class _InitialSidebarItem extends StatefulWidget {
  const _InitialSidebarItem({
    required this.isSelected,
    required this.shortcutCount,
    required this.onTap,
  });

  final bool isSelected;
  final int shortcutCount;
  final VoidCallback onTap;

  @override
  State<_InitialSidebarItem> createState() => _InitialSidebarItemState();
}

class _InitialSidebarItemState extends State<_InitialSidebarItem> {
  static const _accent = Color(0xFF6366F1);
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: isSelected
              ? _accent.withValues(alpha: 0.12)
              : _isHovered
              ? Colors.grey.shade100
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accent.withValues(alpha: 0.35) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? _accent : _accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      color: isSelected ? Colors.white : _accent,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      "Inicio",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? _accent : Colors.black87,
                      ),
                    ),
                  ),
                  if (widget.shortcutCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${widget.shortcutCount}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),
                    )
                  else if (_isHovered)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.grey.shade400,
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
