import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_item_formatters.dart';

class AdjustmentRequestItemTable extends StatelessWidget {
  const AdjustmentRequestItemTable({
    super.key,
    required this.items,
  });

  final List<AdjustmentRequestItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ItemTableHeader(),
        const Divider(height: 1, color: AppThemeTokens.borderLight),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'La solicitud no tiene productos.',
                    style: TextStyle(color: AppThemeTokens.neutral),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: AppThemeTokens.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    return AdjustmentRequestItemTableRow(
                      item: items[index],
                      isEven: index.isEven,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ItemTableHeader extends StatelessWidget {
  const _ItemTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w800,
      color: AppThemeTokens.neutral,
      letterSpacing: 0.2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppThemeTokens.surfaceLight,
      child: const Row(
        children: [
          Expanded(flex: 26, child: Text('PRODUCTO', style: style)),
          Expanded(
            flex: 13,
            child: Text('EXISTENCIA', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 13,
            child: Text('CONTEO REAL', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 13,
            child: Text('DIFERENCIA', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 14,
            child: Text('COSTO', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 14,
            child: Text('SUBTOTAL', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class AdjustmentRequestItemTableRow extends StatelessWidget {
  const AdjustmentRequestItemTableRow({
    super.key,
    required this.item,
    this.isEven = true,
  });

  final AdjustmentRequestItem item;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final factor = UnitConversionTool.ensureSafeFactor(item.conversionFactor);
    final unitName = item.unitName ?? item.standardUnitName ?? '';

    return Container(
      color: isEven ? Colors.white : AppThemeTokens.surfaceLight.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
              ],
            ),
          ),
          Expanded(
            flex: 13,
            child: Text(
              formatAdjustmentDisplayQuantity(item.systemStock, factor),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 13,
            child: Text(
              formatAdjustmentDisplayQuantity(item.countedQuantity, factor),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 13,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  adjustmentDifferenceIcon(item.difference),
                  size: 14,
                  color: adjustmentDifferenceColor(item.difference),
                ),
                const SizedBox(width: 2),
                Text(
                  formatAdjustmentSignedQuantity(item.difference, factor),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: adjustmentDifferenceColor(item.difference),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              formatAdjustmentUnitCost(item.cost, factor),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              NumberFormatter.convertToMoneyLike(item.subtotal),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
