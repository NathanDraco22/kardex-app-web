import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

Future<SaleItem?> showEditSaleItemDialog(BuildContext context, SaleItem item) async {
  return await showDialog<SaleItem>(
    context: context,
    builder: (context) => EditSaleItemDialog(item: item),
  );
}

class EditSaleItemDialog extends StatefulWidget {
  const EditSaleItemDialog({super.key, required this.item});

  final SaleItem item;

  @override
  State<EditSaleItemDialog> createState() => _EditSaleItemDialogState();
}

class _EditSaleItemDialogState extends State<EditSaleItemDialog> {
  late TextEditingController quantityController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.item.quantity.toString());
    // Convert cents to decimal for display (e.g., 1000 -> 10.00)
    priceController = TextEditingController(
      text: (widget.item.price / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Producto"),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: "Cantidad",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Precio Unitario",
                border: OutlineInputBorder(),
                prefixText: "\$ ",
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            final priceDecimal = double.tryParse(priceController.text) ?? 0.0;
            final priceInt = (priceDecimal * 100).round();

            if (quantity <= 0) {
              DialogManager.showErrorDialog(context, "La cantidad debe ser mayor a 0");
              return;
            }

            if (priceInt < 0) {
              DialogManager.showErrorDialog(context, "El precio no puede ser negativo");
              return;
            }

            // Recalculate totals
            // Subtotal = quantity * price
            final subTotal = quantity * priceInt;

            // Recalculate discount based on original percentage
            // If we want to keep fixed discount amount, logic would be different.
            // Requirement says "create new one from another", usually implicit re-calculation.
            // Let's stick to percentage if available.
            final discountPercentage = widget.item.discountPercentage;
            final totalDiscount = (subTotal * (discountPercentage / 100)).round();

            final total = subTotal - totalDiscount;

            final newItem = SaleItem(
              product: widget.item.product,
              selectedPrice: widget.item.selectedPrice,
              quantity: quantity,
              bonQuantity: widget.item.bonQuantity, // Keep bonus? Assume yes.
              cost: widget.item.cost, // Metadata: Cost should probably not change or come from product?
              // The user requirement didn't specify changing cost, only price/quantity.
              // Beware: Changing quantity usually doesn't change unit cost, allowing totalCost recalc downstream.
              price: priceInt,
              subTotal: subTotal,
              discountPercentage: discountPercentage,
              totalDiscount: totalDiscount,
              total: total,
            );

            Navigator.pop(context, newItem);
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
