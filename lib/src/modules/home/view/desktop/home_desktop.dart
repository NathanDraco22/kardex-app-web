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
    final allowedCategories = getHomeModuleCategories(context, widget.currentBranch).where((cat) {
      return cat.permissions.any(
        (p) => AccessManager().hasCurrentAccess(context, p.name),
      );
    }).toList();

    final selectedCategory = _selectedModuleId == null
        ? null
        : allowedCategories.firstWhereOrNull(
            (category) => category.id == _selectedModuleId,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopModuleSidebar(
          categories: allowedCategories,
          selectedModuleId: selectedCategory?.id,
          onSelect: (id) => setState(() => _selectedModuleId = id),
          currentBranch: widget.currentBranch,
        ),
        Expanded(
          child: selectedCategory == null
              ? DesktopInitialPanel(
                  firstName: widget.firstName,
                  currentBranch: widget.currentBranch,
                  onExploreModules: allowedCategories.isEmpty
                      ? null
                      : () => setState(
                          () => _selectedModuleId = allowedCategories.first.id,
                        ),
                )
              : DesktopSubmenuPanel(
                  category: selectedCategory,
                ),
        ),
      ],
    );
  }
}
