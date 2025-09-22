import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/title_label.dart';

class ProductInvoiceCard extends StatelessWidget {
  const ProductInvoiceCard({
    super.key,
    required this.tileColor,
    required this.item,
    required this.percentDiscount,
  });

  final Color tileColor;
  final int percentDiscount;
  final CommercialProductResult item;

  @override
  Widget build(BuildContext context) {
    final priceFormatted = NumberFormatter.convertFromCentsToDouble(item.product.saleProfile.salePrice);
    final discountFormatted = NumberFormatter.convertFromCentsToDouble(item.totalDiscount);
    final totalFormatted = NumberFormatter.convertFromCentsToDouble(item.total);

    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Text(
              item.product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              spacing: 12,
              children: [
                Text(item.product.brandName),
                Text(item.product.unitName),
              ],
            ),
            const Divider(
              height: 2,
            ),

            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.quantity.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // if (item.bonQuantity > 0)
                //   Text(
                //     item.bonQuantity.toString(),
                //     style: const TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 16,
                //     ),
                //   ),
              ],
            ),
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleLabel(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: "Precio",
                  bigTitle: priceFormatted.toString(),
                ),
                TitleLabel(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: "Desc($percentDiscount%)",
                  bigTitle: discountFormatted.toString(),
                ),
                const TitleLabel(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: "IVA(15%)",
                  bigTitle: "0",
                ),
              ],
            ),

            const Divider(height: 1),
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  totalFormatted.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
