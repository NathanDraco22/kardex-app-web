part of '../daily_product_in_orders_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadDailyProductInOrdersCubit>().state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadDailyProductInOrdersLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadDailyProductInOrdersSuccess) {
                return const SizedBox.shrink();
              }

              final products = state.productTotals;

              if (products.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text("No hay productos en pedidos para esta fecha"),
                  ),
                );
              }

              return Expanded(
                child: BasicTableListView(
                  itemCount: products.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text(
                        "Producto",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      flex: 3,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Cantidad",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      flex: 2,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Importe",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      flex: 2,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                    final productSale = products[index];

                    return BasicTableRow(
                      color: rowColor,
                      cells: [
                        BasicTableCell(
                          content: Text(productSale.productName),
                        ),
                        BasicTableCell(
                          content: Text(productSale.totalUnits.toString()),
                        ),
                        BasicTableCell(
                          content: Text(
                            NumberFormatter.convertToMoneyLike(productSale.total),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
