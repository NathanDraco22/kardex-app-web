import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

/// Resumen de totales (Subtotal, Descuentos, Total) del carrito en la Terminal de Venta.
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

  Future<void> _openInvoiceDiscountDialog(BuildContext context) async {
    final baseAmount = viewController.itemsNetTotal;
    if (baseAmount <= 0) return;

    final result = await showDiscountInputDialog(
      context,
      title: 'Descuento de factura',
      baseAmount: baseAmount,
      initialType: viewController.invoiceDiscountType,
      initialValue: viewController.invoiceDiscountValue,
    );
    if (result == null) return;
    viewController.setInvoiceDiscount(result.type, result.value);
  }

  @override
  Widget build(BuildContext context) {
    final subTotal = viewController.itemsSubTotal;
    final itemDiscounts = viewController.itemDiscounts;
    final invoiceDiscount = viewController.invoiceDiscountAmount;
    final totalAmount = viewController.totalAmount;
    final hasInvoiceDiscount = invoiceDiscount > 0;

    final pctLabel =
        viewController.invoiceDiscountType == DiscountType.percentage &&
                viewController.invoiceDiscountValue > 0
            ? '${viewController.invoiceDiscountValue}%'
            : DiscountType.formatEquivalentPercentage(
                discountAmount: invoiceDiscount,
                baseAmount: viewController.itemsNetTotal,
              );
    final invoiceDiscountTag = pctLabel.isNotEmpty ? ' ($pctLabel)' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subtotal",
              style: TextStyle(color: Colors.grey, fontSize: labelFontSize),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(subTotal),
              style: TextStyle(fontSize: labelFontSize),
            ),
          ],
        ),
        if (itemDiscounts > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Desc. productos",
                style: TextStyle(color: Colors.grey, fontSize: labelFontSize),
              ),
              Text(
                "-${NumberFormatter.convertToMoneyLike(itemDiscounts)}",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: labelFontSize,
                ),
              ),
            ],
          ),
        ],
        Gate(
          filters: const [DiscountsGateFilter()],
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: viewController.itemsNetTotal > 0
                  ? () => _openInvoiceDiscountDialog(context)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: labelFontSize,
                          color: hasInvoiceDiscount
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Desc. factura$invoiceDiscountTag",
                          style: TextStyle(
                            color: hasInvoiceDiscount
                                ? Colors.grey.shade800
                                : Colors.blue.shade700,
                            fontSize: labelFontSize,
                            fontWeight: hasInvoiceDiscount
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasInvoiceDiscount
                              ? "-${NumberFormatter.convertToMoneyLike(invoiceDiscount)}"
                              : "Aplicar",
                          style: TextStyle(
                            color: hasInvoiceDiscount
                                ? Colors.red.shade600
                                : Colors.blue.shade700,
                            fontSize: labelFontSize,
                            fontWeight: hasInvoiceDiscount
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                        ),
                        if (hasInvoiceDiscount) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: viewController.clearInvoiceDiscount,
                            child: Icon(
                              Icons.close,
                              size: labelFontSize + 2,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
