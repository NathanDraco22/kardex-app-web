import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_business/kardex_business.dart';

/// Resumen de totales (Subtotal, Descuento, Total) del carrito en la Terminal de Venta.
class TerminalTotalsSummary extends StatelessWidget {
  const TerminalTotalsSummary({
    super.key,
    required this.viewController,
    this.totalFontSize = 20,
    this.labelFontSize = 14,
  });

  final SaleTerminalViewController viewController;
  final double totalFontSize;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final totalAmount = viewController.totalAmount;
    final totalDiscount = viewController.totalDiscount;
    final subTotal = totalAmount + totalDiscount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Subtotal", style: TextStyle(color: Colors.grey, fontSize: labelFontSize)),
            Text(NumberFormatter.convertToMoneyLike(subTotal), style: TextStyle(fontSize: labelFontSize)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Descuento", style: TextStyle(color: Colors.grey, fontSize: labelFontSize)),
            Text(
              "-${NumberFormatter.convertToMoneyLike(totalDiscount)}",
              style: TextStyle(color: Colors.red.shade600, fontSize: labelFontSize),
            ),
          ],
        ),
        const Divider(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: labelFontSize + 2,
              ),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(totalAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: totalFontSize,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
