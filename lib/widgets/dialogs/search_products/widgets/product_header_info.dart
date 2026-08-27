import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class ProductHeaderInfo extends StatelessWidget {
  const ProductHeaderInfo({
    super.key,
    required this.product,
    this.rowAlignment = MainAxisAlignment.center,
    this.rowSpacing = 12,
    this.labelCrossAxisAlignment = CrossAxisAlignment.center,
  });

  final ProductInDbInBranch product;
  final MainAxisAlignment rowAlignment;
  final double? rowSpacing;
  final CrossAxisAlignment labelCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final String codeText = product.code.isNotEmpty
        ? product.code
        : product.displayCode;

    final unitFactorText = product.defaultUnitFactor > 1
        ? ' (${product.defaultUnitFactor % 1 == 0 ? product.defaultUnitFactor.toInt() : product.defaultUnitFactor})'
        : '';
    final brandText = product.brandName.trim();
    final unitText = '${product.unitName}$unitFactorText';
    final subtitle = brandText.isNotEmpty ? '$brandText $unitText' : unitText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ImageViewerWidget(
          imageUrls: product.image.isNotEmpty ? [product.image] : [],
          width: 100,
          height: 100,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.qr_code_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    codeText,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

