part of '../product_catalog_web.dart';

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
                  "Costo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Ultima Compra",
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

          final price = NumberFormatter.convertToMoneyLike(
            currentProduct.saleProfile.salePrice,
          );

          final lastCost = NumberFormatter.convertToMoneyLike(
            currentProduct.account.lastCost,
          );
          return BasicTableRow(
            color: color,
            cells: [
              BasicTableCell(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentProduct.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.qr_code, size: 12),
                        Text(currentProduct.displayCode),
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
                      lastCost,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              BasicTableCell(
                content: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final newProfile = await showProductPriceEditor(context, currentProduct);
                    if (newProfile != null && context.mounted) {
                      final updatedProduct = currentProduct.copyWith(saleProfile: newProfile);
                      context.read<ReadProductInBranchCubit>().markProductAsEdited(updatedProduct);
                    }
                  },
                  child: Text(
                    price,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
