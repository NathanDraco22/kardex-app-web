import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Encabezado de la página de reportes de gastos.
class ExpenseReportHeader extends StatelessWidget {
  const ExpenseReportHeader({super.key, required this.branchName});

  final String branchName;

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
            border: Border.all(
              color: AppThemeTokens.indigo.withValues(alpha: 0.24),
            ),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
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
                'Reporte de Gastos',
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
                'Analiza los egresos operativos y los pagos a proveedores del período seleccionado.',
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

    final branchChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_rounded,
            size: 16,
            color: AppThemeTokens.teal,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              branchName.isEmpty ? 'Sucursal actual' : branchName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 12),
              branchChip,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            branchChip,
          ],
        );
      },
    );
  }
}
