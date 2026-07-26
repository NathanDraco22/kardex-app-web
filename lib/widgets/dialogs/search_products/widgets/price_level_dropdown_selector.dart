import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class PriceLevelDropdownSelector extends StatelessWidget {
  const PriceLevelDropdownSelector({
    super.key,
    required this.result,
    required this.isUserAdmin,
    required this.onChanged,
  });

  final CommercialProductResult result;
  final bool isUserAdmin;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final product = result.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Nivel de Precio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<int>(
          value: result.selectedPriceLevel,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: 1,
              child: Text(
                "Precio 1 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice)})",
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(
                "Precio 2 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice2)})",
              ),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(
                "Precio 3 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice3)})",
              ),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text(
                "Precio 4 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice4)})",
              ),
            ),
            if (isUserAdmin)
              const DropdownMenuItem(
                value: 0,
                child: Text("Precio manual"),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            final priceMap = {
              1: product.saleProfile.salePrice,
              2: product.saleProfile.salePrice2,
              3: product.saleProfile.salePrice3,
              4: product.saleProfile.salePrice4,
            };

            if (priceMap[value] == 0) {
              return;
            }

            result.selectedPriceLevel = value;
            if (value != 0) {
              result.newPrice = priceMap[value]!;
            }
            onChanged();
          },
        ),
      ],
    );
  }
}
