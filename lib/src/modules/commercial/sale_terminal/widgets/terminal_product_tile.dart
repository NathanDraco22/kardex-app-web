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

    return ListenableBuilder(
      listenable: priceLevelListenable,
      builder: (context, _) {
        final isWholesale = priceLevelListenable.isWholesale;
        final unitFactor = _unitFactor(isWholesale);
        final price = _priceForLevel(priceLevelListenable.selectedPriceLevel) * unitFactor;
        final convertedStock = unitFactor > 1 ? stock ~/ unitFactor : stock;
        final cartItem = priceLevelListenable.items.where((i) => i.product.id == product.id).firstOrNull;
        final inCartQuantity = cartItem?.quantity ?? 0;
        final isInCart = inCartQuantity > 0;

        return Card(
          margin: EdgeInsets.zero,
          elevation: isInCart ? 3 : 1,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isInCart
                ? BorderSide(color: Colors.green.shade600, width: 2)
                : BorderSide(color: Colors.grey.shade300, width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                canRequestFocus: false,
                onTap: hasStock ? onTap : null,
                onLongPress: hasStock ? onLongPress : null,
                child: Opacity(
                  opacity: hasStock ? 1.0 : 0.45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 76,
                            height: 76,
                            color: Colors.grey.shade100,
                            child: Center(
                              child: ImageViewerWidget(
                                imageUrls: product.image.isNotEmpty ? [product.image] : [],
                                width: 76,
                                height: 76,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.qr_code, size: 12, color: Colors.grey),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      product.displayCode,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
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
                                  fontSize: 13,
                                  height: 1.15,
                                ),
                              ),
                              if (product.brandName.isNotEmpty)
                                Text(
                                  product.brandName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          NumberFormatter.convertToMoneyLike(price),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: UnitDisplayer(
                                            unitName: _unitName(isWholesale),
                                            conversionFactor: unitFactor,
                                            fallbackUnitName: product.unitName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: hasStock ? Colors.blue.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: hasStock ? Colors.blue.shade200 : Colors.red.shade200,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      NumberFormatter.formatDisplayStock(convertedStock, 1),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: hasStock ? Colors.blue.shade800 : Colors.red.shade700,
                                      ),
                                    ),
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
              if (isInCart)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$inCartQuantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
