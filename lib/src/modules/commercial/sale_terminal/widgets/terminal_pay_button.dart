import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/payment_action.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/buttons/ctrl_key_tip.dart';

/// Botón principal de cobrar en la Terminal de Venta con atajo (Ctrl+G),
/// validaciones de productos con precio en 0 y productos sin cantidad.
class TerminalPayButton extends StatelessWidget {
  const TerminalPayButton({
    super.key,
    required this.viewController,
    this.height = 64,
    this.fontSize = 22,
    this.iconSize = 28,
  });

  final SaleTerminalViewController viewController;
  final double height;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final hasItems = viewController.items.isNotEmpty;
    final hasZeroPrice = viewController.hasZeroPriceItems;
    final hasZeroQuantity = viewController.hasItemsWithZeroQuantity;
    final enabled = hasItems && !hasZeroPrice && !hasZeroQuantity;

    String? disabledMessage;
    if (hasZeroPrice) {
      disabledMessage = "Hay productos con precio en 0. Edítalos o elimínalos para cobrar.";
    } else if (hasZeroQuantity) {
      disabledMessage = "Hay productos sin cantidad. Revisa la venta antes de cobrar.";
    }

    return Tooltip(
      message: disabledMessage ?? "",
      child: CtrlKeyTip(
        hotKey: "G",
        onShortcut: () async {
          await startTerminalPayment(context);
          if (context.mounted) {
            viewController.requestSearchFocus();
          }
        },
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: enabled
                ? () async {
                    await startTerminalPayment(context);
                    if (context.mounted) {
                      viewController.requestSearchFocus();
                    }
                  }
                : null,
            icon: Icon(Icons.payments_outlined, size: iconSize),
            label: const Text("Cobrar"),
          ),
        ),
      ),
    );
  }
}
