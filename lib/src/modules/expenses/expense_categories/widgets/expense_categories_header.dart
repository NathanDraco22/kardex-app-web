import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Encabezado del catálogo de categorías de gastos.
class ExpenseCategoriesHeader extends StatelessWidget {
  const ExpenseCategoriesHeader({
    super.key,
    required this.categoryCount,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onCreate,
  });

  final int categoryCount;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppThemeTokens.indigo.withValues(alpha: 0.12),
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(color: AppThemeTokens.indigo.withValues(alpha: 0.24)),
          ),
          child: const Icon(
            Icons.category_rounded,
            color: AppThemeTokens.indigo,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categorías de Gastos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Organiza los egresos del negocio con etiquetas claras y reutilizables.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusBadge.indigo(
          label: '$categoryCount ${categoryCount == 1 ? 'categoría' : 'categorías'}',
          icon: Icons.sell_outlined,
        ),
        IconButton(
          onPressed: isRefreshing ? null : onRefresh,
          tooltip: 'Actualizar categorías',
          icon: isRefreshing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded, size: 21),
          color: const Color(0xFF475569),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: const Size(44, 44),
            shape: RoundedRectangleBorder(
              borderRadius: AppThemeTokens.borderRadiusMd,
              side: const BorderSide(color: AppThemeTokens.borderLight),
            ),
          ),
        ),
        PrimaryMenuButton(
          onPressed: onCreate,
          backgroundColor: AppThemeTokens.indigo,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Nueva Categoría',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}
