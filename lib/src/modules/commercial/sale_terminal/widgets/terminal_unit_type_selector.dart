import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';

/// Selector segmentado para alternar entre venta Detalle y Mayorista.
class TerminalUnitTypeSelector extends StatelessWidget {
  const TerminalUnitTypeSelector({
    super.key,
    required this.viewController,
    this.isCompact = false,
    this.fontSize = 12,
  });

  final SaleTerminalViewController viewController;
  final bool isCompact;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final detailLabel = isCompact ? "Detalle" : "Venta Detalle";
    final wholesaleLabel = isCompact ? "Mayorista" : "Venta Mayorista";

    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        return SegmentedButton<bool>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          segments: [
            ButtonSegment(
              value: false,
              label: Text(detailLabel),
              icon: isCompact ? null : const Icon(Icons.shopping_basket_outlined, size: 16),
            ),
            ButtonSegment(
              value: true,
              label: Text(wholesaleLabel),
              icon: isCompact ? null : const Icon(Icons.inventory_2_outlined, size: 16),
            ),
          ],
          selected: {viewController.isWholesale},
          onSelectionChanged: (selection) {
            viewController.isWholesale = selection.first;
            viewController.requestSearchFocus();
          },
        );
      },
    );
  }
}
