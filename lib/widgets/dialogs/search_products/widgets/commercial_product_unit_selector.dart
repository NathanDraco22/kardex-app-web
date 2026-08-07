import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class CommercialProductUnitSelector extends StatelessWidget {
  const CommercialProductUnitSelector({
    super.key,
    required this.result,
    required this.onChanged,
    this.focusNode,
  });

  final CommercialProductResult result;
  final VoidCallback onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final product = result.product;
    final List<DropdownMenuItem<int>> items = [
      DropdownMenuItem<int>(
        value: 0,
        child: Text(product.unitName),
      ),
      ...List.generate(product.extraUnits.length, (index) {
        final extra = product.extraUnits[index];
        return DropdownMenuItem<int>(
          value: index + 1,
          child: Text('${extra.name} (x${extra.conversionFactor})'),
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Unidad de Venta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          focusNode: focusNode,
          initialValue: result.selectedUnitIndex,
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          items: items,
          onChanged: (value) {
            if (value == null) return;
            result.selectedUnitIndex = value;
            if (value == 0) {
              result.conversionFactor = 1;
              result.selectedUnitName = product.unitName;
            } else {
              final extra = product.extraUnits[value - 1];
              result.conversionFactor = extra.conversionFactor;
              result.selectedUnitName = extra.name;
            }
            onChanged();
          },
        ),
      ],
    );
  }
}
