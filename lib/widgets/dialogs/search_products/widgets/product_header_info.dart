import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

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
    return Column(
      children: [
        Center(
          child: ImageViewerWidget(
            imageUrls: product.image.isNotEmpty ? [product.image] : [],
            width: 90,
            height: 90,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Text(
          product.displayCode,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: rowAlignment,
          spacing: rowSpacing ?? 0,
          children: [
            TitleLabel(
              title: "Marca",
              bigTitle: product.brandName,
              crossAxisAlignment: labelCrossAxisAlignment,
            ),
            TitleLabel(
              title: "Unidad",
              bigTitle: product.unitName,
              crossAxisAlignment: labelCrossAxisAlignment,
            ),
          ],
        ),
      ],
    );
  }
}
