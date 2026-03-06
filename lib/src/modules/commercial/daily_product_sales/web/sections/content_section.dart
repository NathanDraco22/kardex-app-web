part of '../daily_product_sales_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadDailyProductSalesCubit>().state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadDailyProductSalesLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadDailyProductSalesSuccess) {
                return const SizedBox.shrink();
              }

              final products = state.productTotals;

              if (products.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text("No hay ventas de productos para esta fecha"),
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
