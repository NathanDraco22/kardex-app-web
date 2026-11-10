import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Selector tipo píldora entre la vista de detalle y el consolidado.
class ExpenseReportViewToggle extends StatelessWidget {
  const ExpenseReportViewToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppThemeTokens.borderRadiusFull,
          border: Border.all(color: AppThemeTokens.borderLight),
          boxShadow: AppThemeTokens.subtleCardShadow(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TogglePill(
              label: 'Detalle',
              icon: Icons.list_alt_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            const SizedBox(width: 3),
            _TogglePill(
              label: 'Consolidado',
              icon: Icons.donut_large_rounded,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeTokens.borderRadiusFull,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppThemeTokens.indigo : Colors.transparent,
          borderRadius: AppThemeTokens.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
