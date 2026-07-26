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
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageViewerWidget(
                    imageUrls: product.image.isNotEmpty ? [product.image] : [],
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.qr_code, size: 12),
                            Text(product.code ?? "-"),
                          ],
                        ),
                        Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.brandName,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                product.defaultUnitName,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BasicTableCell(
              content: Text(
                NumberFormatter.formatDisplayStock(inventory.currentStock, product.defaultUnitFactor),
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                NumberFormatter.convertToMoneyLike(inventory.averageCost * product.defaultUnitFactor),
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
