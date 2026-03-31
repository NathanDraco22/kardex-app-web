part of '../product_inventory_catalog_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadProductInBranchCubit>().state;

    if (state is ReadProductInBranchLoading) {
      return const Column(
        children: [
          LinearProgressIndicator(),
        ],
      );
    }

    if (state is ReadProductInBranchFailure) {
      return Center(child: Text(state.message));
    }

    if (state is! ReadProductInBranchSuccess) {
      return const SizedBox.shrink();
    }

    final products = state.products;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final maxScrollExtend = notification.metrics.maxScrollExtent;
        final scrollOffset = notification.metrics.pixels;
        final nextPageThreshold = maxScrollExtend * 0.65;

        if (scrollOffset >= nextPageThreshold) {
          context.read<ReadProductInBranchCubit>().getNextPage();
        }
        return false;
      },
      child: BasicTableListView(
        columns: [
          BasicTableColumn(
            flex: 4,
            label: const Text(
              "Producto",
            ),
          ),

          BasicTableColumn(
            flex: 2,
            label: Column(
              children: [
                Text(
                  "Costo Promedio",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Existencia (Stock)",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          BasicTableColumn(
            flex: 2,
            label: const Text(
              "Precio",
              textAlign: TextAlign.center,
            ),
          ),
        ],
        itemCount: products.length,
        rowBuilder: (context, index) {
          Color color = index.isOdd ? Colors.white : Colors.grey.shade200;

          final product = products[index];
          final editedIndex = state.editedProducts.indexWhere((p) => p.id == product.id);
          final currentProduct = editedIndex >= 0 ? state.editedProducts[editedIndex] : product;

          if (editedIndex >= 0) {
            color = Colors.blue.shade100;
          }

          final averageCost = NumberFormatter.convertToMoneyLike(
            currentProduct.account.averageCost,
          );

          final stock = currentProduct.account.currentStock.toString();

          final price = NumberFormatter.convertToMoneyLike(
            currentProduct.saleProfile.salePrice,
          );

          return BasicTableRow(
            color: color,
            cells: [
              BasicTableCell(
                content: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.normal),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    final updatedProduct = await showProductInventoryEditor(context, currentProduct);
                    if (updatedProduct != null && context.mounted) {
                      context.read<ReadProductInBranchCubit>().markProductAsEdited(updatedProduct);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        currentProduct.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.qr_code, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(currentProduct.displayCode, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              currentProduct.brandName,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              currentProduct.unitName,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              BasicTableCell(
                content: Column(
                  children: [
                    Text(
                      averageCost,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stock,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentProduct.account.currentStock > 0 ? Colors.green.shade900 : Colors.red.shade900,
                      )
                    ),
                  ],
                ),
              ),
              BasicTableCell(
                content: Text(
                  price,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
