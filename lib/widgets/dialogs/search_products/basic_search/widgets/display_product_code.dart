import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';

class DisplayProductCode extends StatelessWidget {
  const DisplayProductCode({
    super.key,
    required this.product,
  });

  final ProductInDb product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: .center,
      children: [
        Text(
          product.name,
          maxLines: 1,
          overflow: .ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.qr_code, size: 12),
            Text(product.displayCode),
          ],
        ),
      ],
    );
  }
}
