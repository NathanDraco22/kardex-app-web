import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_item_formatters.dart';

class AdjustmentRequestItemCards extends StatelessWidget {
  const AdjustmentRequestItemCards({
    super.key,
    required this.items,
  });

  final List<AdjustmentRequestItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('La solicitud no tiene productos.')),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          AdjustmentRequestItemCard(item: items[index]),
          if (index < items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class AdjustmentRequestItemCard extends StatelessWidget {
  const AdjustmentRequestItemCard({
    super.key,
    required this.item,
  });

  final AdjustmentRequestItem item;

  @override
  Widget build(BuildContext context) {
    final factor = UnitConversionTool.ensureSafeFactor(item.conversionFactor);
    final unitName = item.unitName ?? item.standardUnitName ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            [
              if ((item.code ?? '').isNotEmpty) item.code!,
              if ((item.brandName ?? '').isNotEmpty) item.brandName!,
              if (unitName.isNotEmpty) unitName,
            ].join(' · '),
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _ValueColumn(
                label: 'Existencia',
                value: formatAdjustmentDisplayQuantity(item.systemStock, factor),
              ),
              _ValueColumn(
                label: 'Conteo real',
                value: formatAdjustmentDisplayQuantity(item.countedQuantity, factor),
              ),
              _ValueColumn(
                label: 'Diferencia',
                value: formatAdjustmentSignedQuantity(item.difference, factor),
                color: adjustmentDifferenceColor(item.difference),
              ),
              _ValueColumn(
                label: 'Costo',
                value: formatAdjustmentUnitCost(item.cost, factor),
              ),
              _ValueColumn(
                label: 'Subtotal',
                value: NumberFormatter.convertToMoneyLike(item.subtotal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppThemeTokens.neutral,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
