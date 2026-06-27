part of '../product_entry_history_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadProductEntryHistoryCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder(
          bloc: readCubit,
          builder: (context, state) {
            if (state is ReadProductEntryHistoryInitial) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 80,
                      color: Colors.grey,
                    ),
                    Text(
                      "Busca un producto para ver su historial de entradas",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ReadProductEntryHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReadProductEntryHistoryError) {
              return Center(child: Text(state.message));
            }

            state as ReadProductEntryHistorySuccess;

            final currentProduct = state.product;

            if (state.entryHistories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Colors.grey,
                    ),
                    Text(
                      "No hay entradas registradas para el producto: ${currentProduct.name}",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                DisplayProductCode(product: currentProduct),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(currentProduct.brandName),
                    Text(currentProduct.unitName),
                  ],
                ),

                const Divider(),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Fecha",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Proveedor",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Costo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  thickness: 1,
                  height: 8.0,
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: state.entryHistories.length,
                    itemBuilder: (context, index) {
                      final entryHistory = state.entryHistories[index];
                      final rowColor = index.isOdd ? Colors.white : Colors.grey.shade100;

                      final entryItem = entryHistory.items.firstWhere(
                        (item) => item.productId == currentProduct.id,
                        orElse: () => EntryItem(productId: '', productName: '', cost: 0, quantity: 0),
                      );

                      final dateStr = DateTimeTool.formatddMMyy(entryHistory.docDate);
                      final costStr = NumberFormatter.convertFromCentsToUnitsCurrency(entryItem.cost);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          hoverColor: Colors.amber.shade100,
                          onTap: () => showEntryHistoryViewerDialog(context, entryHistory),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: rowColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dateStr,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entryHistory.supplier.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    costStr,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
