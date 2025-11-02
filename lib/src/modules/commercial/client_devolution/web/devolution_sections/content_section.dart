part of '../devolution_selection_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final invoice = context.findAncestorWidgetOfExactType<_Body>()!.invoice;
    final devolutions = context.findAncestorWidgetOfExactType<_Body>()!.devolutions;
    final viewController = DevolutionSelectionMediator.of(context).notifier!;
    final targetDevolutions = devolutions.where((devolution) => devolution.originalInvoiceId == invoice.id).toList();
    final returnedItems = targetDevolutions.fold<List<SaleItem>>(
      [],
      (previousValue, devolution) => [...previousValue, ...devolution.returnedItems],
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
                final hasItemReturned = returnedItems.any((returnedItem) => returnedItem.product.id == item.product.id);
                return CheckboxListTile(
                  enabled: !hasItemReturned,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(item.product.name),
                  subtitle: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.product.brandName)),
                      Expanded(
                        flex: 1,
                        child: Text(item.quantity.toString(), textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          NumberFormatter.convertToMoneyLike(item.price),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  value: viewController.isInSelected(item),
                  onChanged: (bool? value) {
                    if (value == true) {
                      viewController.addToSelected(item);
                    } else {
                      viewController.removeFromSelected(item);
                    }
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
