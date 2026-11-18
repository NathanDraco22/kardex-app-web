import 'package:kardex_app_front/widgets/dialogs/discount_input_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

/// Controles reutilizables para aplicar descuentos predefinidos o manuales (% / monto)
/// sobre una línea de producto en diálogo/modal comercial.
class ProductDiscountControls extends StatelessWidget {
  const ProductDiscountControls({
    super.key,
    required this.result,
    required this.onChanged,
  });

  final CommercialProductResult result;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final predefined = result.product.saleProfile.discounts
        .where((d) => d.isActive)
        .toList();
    final hasDiscount = result.totalDiscount > 0;
    final discountLabel = switch (result.effectiveDiscountType) {
      DiscountType.percentage =>
        'Descuento: ${result.discountPercent}% (-${NumberFormatter.convertToMoneyLike(result.totalDiscount)})',
      DiscountType.amount =>
        'Descuento: -${NumberFormatter.convertToMoneyLike(result.totalDiscount)}',
      null => 'Aplicar descuento (% o monto)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (predefined.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: predefined.map((d) {
              final isSelected =
                  result.selectedDiscount == d &&
                  result.manualDiscountType == null;
              return ChoiceChip(
                label: Text('${d.name} (${d.percentValue}%)'),
                selected: isSelected,
                onSelected: (selected) {
                  result.applyPredefinedDiscount(selected ? d : null);
                  onChanged();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(
                  hasDiscount
                      ? Icons.local_offer
                      : Icons.local_offer_outlined,
                  size: 18,
                  color: hasDiscount ? Colors.orange.shade700 : null,
                ),
                label: Text(
                  discountLabel,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: result.subTotal <= 0
                    ? null
                    : () async {
                        final initialType = result.effectiveDiscountType;
                        final initialValue = initialType == DiscountType.percentage
                            ? result.discountPercent
                            : (initialType == DiscountType.amount
                                ? result.manualDiscountValue
                                : 0);
                        final res = await showDiscountInputDialog(
                          context,
                          title: 'Descuento del producto',
                          baseAmount: result.subTotal,
                          initialType: initialType,
                          initialValue: initialValue,
                        );
                        if (res == null) return;
                        result.applyManualDiscount(res.type, res.value);
                        onChanged();
                      },
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Quitar descuento',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  result.clearDiscount();
                  onChanged();
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
