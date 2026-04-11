part of '../product_demand_vs_stock_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadProductStockDemandCubit>().state;

    return Card(
      child: Column(
        children: [
          if (state is ReadProductStockDemandLoading) const LinearProgressIndicator(),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state is ReadProductStockDemandError) {
                  return Center(child: Text(state.message));
                }

                if (state is! ReadProductStockDemandSuccess) {
                  return const SizedBox.shrink();
                }

                final results = state.results;

                if (results.isEmpty) {
                  return const Center(child: Text("No hay demanda de productos en borrador."));
                }

                return BasicTableListView(
                  itemCount: results.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text("Producto", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 3,
                    ),
                    BasicTableColumn(
                      label: const Align(
                        alignment: Alignment.center,
                        child: Text("Pedido", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    BasicTableColumn(
                      label: const Align(
                        alignment: Alignment.center,
                        child: Text("Inventario", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    BasicTableColumn(
                      label: const Align(
                        alignment: Alignment.center,
                        child: Text("Faltante", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final item = results[index];
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade100;
                    final totalDemand = item.totalOrdered + item.totalBonification;

                    return BasicTableRow(
                      color: rowColor,
                      cells: [
                        BasicTableCell(content: Text(item.productName)),
                        BasicTableCell(
                          content: Align(
                            alignment: Alignment.center,
                            child: Text(totalDemand.toString()),
                          ),
                        ),
                        BasicTableCell(
                          content: Align(
                            alignment: Alignment.center,
                            child: Text(item.currentStock.toString()),
                          ),
                        ),
                        BasicTableCell(
                          content: Align(
                            alignment: Alignment.center,
                            child: Text(
                              item.shortage.toString(),
                              style: TextStyle(
                                color: item.shortage < 0 ? Colors.red : Colors.green,
                                fontWeight: item.shortage > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
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
