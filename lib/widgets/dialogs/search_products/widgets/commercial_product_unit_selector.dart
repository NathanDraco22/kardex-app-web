import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/elements/quantity_unit_rules.dart';
import 'package:kardex_business/kardex_business.dart';

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
          child: Text(extra.name),
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
            if (value < 0 || value > product.extraUnits.length) return;

            final oldFactor = UnitConversionTool.ensureSafeFactor(result.conversionFactor);
            final int newFactor;
            final String newUnitName;
            if (value == 0) {
              newFactor = 1;
              newUnitName = product.unitName;
            } else {
              final extra = product.extraUnits[value - 1];
              newFactor = UnitConversionTool.ensureSafeFactor(extra.conversionFactor);
              newUnitName = extra.name;
            }

            final isNewUnitSuperior = QuantityUnitRules.isSuperiorUnit(
              selectedUnitIndex: value,
              defaultUnitIndex: product.defaultUnitIndex,
            );
            final previousQuantity = result.quantity;
            final convertedQuantity = QuantityUnitRules.convertOnUnitChange(
              displayQuantity: previousQuantity,
              oldFactor: oldFactor,
              newFactor: newFactor,
              newUnitIsSuperior: isNewUnitSuperior,
            );

            result.quantity = convertedQuantity ?? 0;
            result.selectedUnitIndex = value;
            result.conversionFactor = newFactor;
            result.selectedUnitName = newUnitName;

            onChanged();
          },
        ),
      ],
    );
  }
}
