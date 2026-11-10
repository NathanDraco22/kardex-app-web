import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/inventory_unit_tool.dart';

/// Muestra una cantidad de stock en la unidad de venta y, si aplica, también
/// en la unidad base del producto.
class StockQuantityLabel extends StatelessWidget {
  const StockQuantityLabel({
    super.key,
    required this.baseStock,
    required this.baseUnitName,
    required this.displayUnitName,
    required this.displayUnitFactor,
    this.title,
    this.color,
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showBase = true,
  });

  final int baseStock;
  final String baseUnitName;
  final String displayUnitName;
  final int displayUnitFactor;

  final String? title;
  final Color? color;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  /// Si es `false`, solo muestra la cantidad en la unidad de venta.
  final bool showBase;

  @override
  Widget build(BuildContext context) {
    final hasConversion =
        displayUnitFactor > 1 && displayUnitName.trim().isNotEmpty && displayUnitName != baseUnitName;

    final primaryText = hasConversion
        ? "${InventoryUnitTool.formatBaseStock(baseStock, displayUnitFactor)} $displayUnitName"
        : "$baseStock $baseUnitName";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (title != null) Text(title!, textAlign: textAlign),
        Text(
          primaryText,
          textAlign: textAlign,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        if (hasConversion && showBase) ...[
          const SizedBox(height: 2),
          Text(
            "Base: $baseStock $baseUnitName",
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
