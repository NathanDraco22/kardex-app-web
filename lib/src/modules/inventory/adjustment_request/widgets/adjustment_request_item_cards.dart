import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/super_widgets/image_viewer_widget.dart';
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
      return const Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('La solicitud no tiene productos.')),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            AdjustmentRequestItemCard(
              item: items[index],
              index: index,
            ),
            if (index < items.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          ],
        ],
      ),
    );
  }
}

class AdjustmentRequestItemCard extends StatelessWidget {
  const AdjustmentRequestItemCard({
    super.key,
    required this.item,
    this.index = 0,
  });

  final AdjustmentRequestItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final factor = UnitConversionTool.ensureSafeFactor(item.conversionFactor);
    final unitName = item.unitName ?? item.standardUnitName ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      color: RowColorTool.getRowColor(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Nombre y Badge de Unidad
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageViewerWidget(
                imageUrls: item.image.isNotEmpty ? [item.image] : [],
                width: 46,
                height: 46,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
              if (factor > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    unitName,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Fila 1: Existencia y Costo unitario
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'Existencia',
                  value: '${formatAdjustmentDisplayQuantity(item.systemStock, factor)} $unitName',
                  subValue: factor > 1 ? '= ${item.systemStock} ${item.standardUnitName ?? ""}' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  label: 'Costo unitario',
                  value: NumberFormatter.convertToMoneyLike(item.cost),
                  subValue: factor > 1
                      ? 'Base: ${NumberFormatter.convertToMoneyLike((item.cost / factor).round())}'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fila 2: Conteo real, Diferencia y Subtotal
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'Conteo real',
                  value: '${formatAdjustmentDisplayQuantity(item.countedQuantity, factor)} $unitName',
                  subValue: factor > 1 ? '= ${item.countedQuantity} ${item.standardUnitName ?? ""}' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  label: 'Diferencia',
                  value: formatAdjustmentSignedQuantity(item.difference, factor),
                  color: adjustmentDifferenceColor(item.difference),
                  icon: adjustmentDifferenceIcon(item.difference),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  label: 'Subtotal',
                  value: NumberFormatter.convertToMoneyLike(item.subtotal),
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
    this.subValue,
    this.color,
    this.icon,
  });

  final String label;
  final String value;
  final String? subValue;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.neutral,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: color ?? const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (subValue != null) ...[
            const SizedBox(height: 1),
            Text(
              subValue!,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
