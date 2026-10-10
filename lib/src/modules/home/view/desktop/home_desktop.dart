part of '../home_screen.dart';

class _HomeDesktopBody extends StatefulWidget {
  final String firstName;
  final BranchInDb? currentBranch;

  const _HomeDesktopBody({
    required this.firstName,
    this.currentBranch,
  });

  @override
  State<_HomeDesktopBody> createState() => _HomeDesktopBodyState();
}

class _HomeDesktopBodyState extends State<_HomeDesktopBody> {
  HomeModuleId? _selectedModuleId;

  @override
  Widget build(BuildContext context) {
    final allCategories = getHomeModuleCategories(context, widget.currentBranch);
    final allowedCategories = allCategories.where((cat) {
      return cat.permissions.any(
        (p) => AccessManager().hasCurrentAccess(context, p.name),
      );
    }).toList();

    if (allowedCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            "No tienes permisos asignados para acceder a los módulos de esta sucursal.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    final activeId = _selectedModuleId != null &&
            allowedCategories.any((c) => c.id == _selectedModuleId)
        ? _selectedModuleId!
        : allowedCategories.first.id;

    final selectedCategory = allowedCategories.firstWhere(
      (c) => c.id == activeId,
      orElse: () => allowedCategories.first,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopModuleSidebar(
          categories: allowedCategories,
          selectedModuleId: activeId,
          onSelect: (id) => setState(() => _selectedModuleId = id),
          currentBranch: widget.currentBranch,
        ),
        Expanded(
          child: DesktopSubmenuPanel(
            category: selectedCategory,
          ),
        ),
      ],
    );
  }
}
