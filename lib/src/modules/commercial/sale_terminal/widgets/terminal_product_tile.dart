import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class TerminalProductTile extends StatelessWidget {
  const TerminalProductTile({
    super.key,
    required this.product,
    required this.priceLevelListenable,
    required this.onTap,
    required this.onLongPress,
  });

  final ProductInDbInBranch product;
  final SaleTerminalViewController priceLevelListenable;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  int _priceForLevel(int level) {
    final priceMap = {
      1: product.saleProfile.salePrice,
      2: product.saleProfile.salePrice2,
      3: product.saleProfile.salePrice3,
      4: product.saleProfile.salePrice4,
    };
    return priceMap[level] ?? product.saleProfile.salePrice;
  }

  String _unitName(bool isWholesale) {
    if (isWholesale && product.wholesaleUnitIndex > 0) {
      final idx = product.wholesaleUnitIndex - 1;
      if (idx >= 0 && idx < product.extraUnits.length) {
        return product.extraUnits[idx].name;
      }
    }
    return product.defaultUnitName;
  }

  int _unitFactor(bool isWholesale) {
    if (isWholesale && product.wholesaleUnitIndex > 0) {
      final idx = product.wholesaleUnitIndex - 1;
      if (idx >= 0 && idx < product.extraUnits.length) {
        return product.extraUnits[idx].conversionFactor;
      }
    }
    return product.defaultUnitFactor;
  }

  @override
  Widget build(BuildContext context) {
    final stock = product.account.availableStock;
    final hasStock = stock > 0;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 10,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        canRequestFocus: false,
        onTap: hasStock ? onTap : null,
        onLongPress: hasStock ? onLongPress : null,
        child: Opacity(
          opacity: hasStock ? 1.0 : 0.45,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 80,
                    child: Center(
                      child: ImageViewerWidget(
                        imageUrls: product.image.isNotEmpty ? [product.image] : [],
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.qr_code, size: 14),
                            Expanded(
                              child: Text(
                                product.displayCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListenableBuilder(
                              listenable: priceLevelListenable,
                              builder: (context, _) {
                                final isWholesale = priceLevelListenable.isWholesale;
                                final unitFactor = _unitFactor(isWholesale);
                                final price = _priceForLevel(priceLevelListenable.selectedPriceLevel) * unitFactor;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      NumberFormatter.convertToMoneyLike(price),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    UnitDisplayer(
                                      unitName: _unitName(isWholesale),
                                      conversionFactor: unitFactor,
                                      fallbackUnitName: product.unitName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            ListenableBuilder(
                              listenable: priceLevelListenable,
                              builder: (context, _) {
                                final unitFactor = _unitFactor(priceLevelListenable.isWholesale);
                                final convertedStock = unitFactor > 1 ? stock ~/ unitFactor : stock;
                                return Text(
                                  NumberFormatter.formatDisplayStock(convertedStock, 1),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: hasStock ? Colors.blue.shade800 : Colors.red.shade700,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}
