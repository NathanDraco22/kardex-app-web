part of '../devolution_selection_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final bodyWidget = context.findAncestorWidgetOfExactType<_Body>()!;
    final invoice = bodyWidget.invoice;
    final devolutions = bodyWidget.devolutions;
    final creditNotes = bodyWidget.creditNotes;
    final viewController = DevolutionSelectionMediator.of(context).notifier!;
    final targetDevolutions = devolutions.where((devolution) => devolution.originalInvoiceId == invoice.id).toList();
    final returnedByLine = computePreviouslyReturnedByLine(
      saleItems: invoice.saleItems,
      devolutions: targetDevolutions,
      creditNotes: creditNotes,
    );

    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Productos para devolución",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(height: 0.0),
              itemCount: invoice.saleItems.length,
              itemBuilder: (context, index) {
                final item = invoice.saleItems[index];
                final hasItemReturned = (returnedByLine[index] ?? 0) > 0;
                return CheckboxListTile(
                  enabled: !hasItemReturned,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(item.product.name),
                  subtitle: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.product.brandName)),
                      Expanded(
                        flex: 1,
                        child: Text(item.formattedDisplayQuantity, textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          NumberFormatter.convertToMoneyLike(item.displayUnitPrice),
                          textAlign: TextAlign.right,
                        ),
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
        ],
      ),
    );
  }
}
