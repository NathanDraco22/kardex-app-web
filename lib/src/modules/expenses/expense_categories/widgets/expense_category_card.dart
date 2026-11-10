import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

const List<Color> _categoryPalette = [
  AppThemeTokens.indigo,
  AppThemeTokens.teal,
  AppThemeTokens.purple,
  AppThemeTokens.info,
  AppThemeTokens.success,
  AppThemeTokens.warning,
  AppThemeTokens.danger,
];

/// Color estable y determinístico para una categoría según su nombre.
Color expenseCategoryAccent(String name) {
  if (name.isEmpty) return AppThemeTokens.indigo;

  var hash = 0;
  for (final codeUnit in name.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return _categoryPalette[hash % _categoryPalette.length];
}

/// Tarjeta de una categoría de gastos dentro del catálogo.
class ExpenseCategoryCard extends StatelessWidget {
  const ExpenseCategoryCard({
    super.key,
    required this.category,
    required this.isNew,
    required this.isUpdated,
    required this.onEdit,
  });

  final ExpenseCategoryInDb category;
  final bool isNew;
  final bool isUpdated;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accent = expenseCategoryAccent(category.name);
    final description = category.description?.trim() ?? '';
    final hasActivityBadge = isNew || isUpdated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(color: accent.withValues(alpha: 0.24)),
                ),
                child: Icon(Icons.category_rounded, color: accent, size: 22),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Editar categoría',
                icon: const Icon(Icons.edit_outlined, size: 19),
                color: const Color(0xFF64748B),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppThemeTokens.borderRadiusSm,
                    side: const BorderSide(color: AppThemeTokens.borderLight),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description.isEmpty ? 'Sin descripción' : description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.3,
              fontStyle: description.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const Spacer(),
          if (!category.isActive || hasActivityBadge)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (!category.isActive)
                  AppStatusBadge.neutral(
                    label: 'Inactiva',
                    icon: Icons.visibility_off_outlined,
                  ),
                if (isNew)
                  AppStatusBadge.indigo(
                    label: 'Nueva',
                    icon: Icons.auto_awesome_rounded,
                  )
                else if (isUpdated)
                  AppStatusBadge.teal(
                    label: 'Actualizada',
                    icon: Icons.sync_rounded,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
