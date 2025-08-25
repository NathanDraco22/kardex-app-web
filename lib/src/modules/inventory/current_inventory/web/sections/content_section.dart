part of '../current_inventory_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.state,
  });

  final ReadCurrentInventorySuccess state;

  @override
  Widget build(BuildContext context) {
    return BasicTableListView(
      columns: [
        BasicTableColumn(label: const Text("Nombre Producto"), flex: 2),
        BasicTableColumn(
          label: const Text(
            "Marca",
            textAlign: TextAlign.center,
          ),
          flex: 1,
        ),
        BasicTableColumn(
          label: const Text(
            "Unidad",
            textAlign: TextAlign.center,
          ),
          flex: 1,
        ),
        BasicTableColumn(
          label: const Text(
            "Existencia",
            textAlign: TextAlign.center,
          ),
          flex: 1,
        ),
        BasicTableColumn(label: const Text("Costo Unitario", textAlign: TextAlign.center), flex: 1),
        BasicTableColumn(label: const Text("Costo Total", textAlign: TextAlign.center), flex: 1),
      ],
      itemCount: state.inventories.length,
      rowBuilder: (context, index) {
        final inventory = state.inventories[index];
        final product = inventory.product;
        final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
        return BasicTableRow(
          color: rowColor,
          cells: [
            BasicTableCell(
              content: Text(product.name),
            ),
            BasicTableCell(
              content: Text(
                product.brandName,
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                product.unitName,
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                inventory.currentStock.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                NumberFormatter.convertToMoneyLike(inventory.averageCost),
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                NumberFormatter.convertToMoneyLike(inventory.total),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
