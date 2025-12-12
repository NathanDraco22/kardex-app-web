import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class SaleItemRow extends StatelessWidget {
  const SaleItemRow({
    super.key,
    required this.saleItem,
    this.color,
    this.onTap,
  });

  final SaleItem saleItem;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Center(
                  child: Text(
                    saleItem.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      saleItem.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(saleItem.product.brandName),
                        ),

                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(saleItem.product.unitName),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final price = NumberFormatter.convertToMoneyLike(
                        saleItem.total,
                      );
                      return Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
