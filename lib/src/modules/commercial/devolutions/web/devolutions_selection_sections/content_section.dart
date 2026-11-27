part of '../devolutions_selection_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final bodyWidget = context.findAncestorWidgetOfExactType<_Body>()!;
    final invoice = bodyWidget.invoice;
    final devolutions = bodyWidget.devolutions;
    final creditNotes = bodyWidget.creditNotes;
    final viewController = DevolutionsSelectionMediator.of(context).notifier!;
    final targetDevolutions =
        devolutions.where((devolution) => devolution.originalInvoiceId == invoice.id).toList();
    final returnedByLine = computePreviouslyReturnedByLine(
      saleItems: invoice.saleItems,
      devolutions: targetDevolutions,
      creditNotes: creditNotes,
    );

    final selectedItems = viewController.selectedItems;
    final selectedTotal = selectedItems.fold<int>(0, (sum, item) => sum + item.total);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Productos para devolución (${invoice.saleItems.length})",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (selectedItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: viewController.clearSelected,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text("Limpiar selección"),
                  ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(height: 0.0),
              itemCount: invoice.saleItems.length,
              itemBuilder: (context, index) {
                final item = invoice.saleItems[index];
                final returnedQty = returnedByLine[index] ?? 0;
                final hasItemReturned = returnedQty > 0;
                final isPartialReturned = hasItemReturned && returnedQty < item.quantity;
                final productCode = item.product.code;
                final hasCode = productCode != null && productCode.isNotEmpty;
                final unitPriceText = NumberFormatter.convertToMoneyLike(item.displayUnitPrice);
                final lineTotalText = NumberFormatter.convertToMoneyLike(item.total);

                return CheckboxListTile(
                  enabled: !hasItemReturned,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (hasItemReturned)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPartialReturned ? "Devuelto parcial (NC)" : "Ya devuelto",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 10,
                        runSpacing: 2,
                        children: [
                          if (hasCode)
                            Text(
                              "Cód: $productCode",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          if (item.product.brandName.isNotEmpty)
                            Text(
                              item.product.brandName,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          Text(
                            item.displayUnitName,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Cant: ${item.formattedDisplayQuantity}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (item.bonQuantity > 0)
                            Text(
                              " (+${item.formattedDisplayBonQuantity} bonif.)",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          const Text("  ×  "),
                          Text(unitPriceText),
                          const Spacer(),
                          Text(
                            lineTotalText,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  value: viewController.isIndexSelected(index),
                  onChanged: (bool? value) {
                    viewController.toggleIndex(
                      index,
                      item.copyWith(invoiceItemIndex: index),
                      value == true,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                Text(
                  "${selectedItems.length} ${selectedItems.length == 1 ? 'producto seleccionado' : 'productos seleccionados'}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Text(
                  "Total a devolver: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  NumberFormatter.convertToMoneyLike(selectedTotal),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
