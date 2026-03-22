part of '../product_movements_screen_mobile.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadProductTransactionCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder(
          bloc: readCubit,
          builder: (context, state) {
            if (state is ReadProductTransactionInitial) {
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
                      "Busca un producto",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ReadProductTransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReadProductTransactionError) {
              return Center(child: Text(state.message));
            }

            state as ReadProductTransactionSuccess;

            final currentProduct = state.product;

            return Column(
              children: [
                DisplayProductCode(product: currentProduct),
                Row(
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
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Documento",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        flex: 2,

                        child: Text(
                          "Costo",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,

                        child: Column(
                          children: [
                            Text(
                              "Cantidad",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Existencia",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  thickness: 1,
                  height: 0.0,
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final currentTransaction = state.transactions[index];

                        final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                        if (index < state.transactions.length - 1) {
                          final nextTransaction = state.transactions[index + 1];
                          if (currentTransaction.createdAt.day != nextTransaction.createdAt.day) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                  ),
                                  child: Text(
                                    DateTimeTool.formatddMMyy(currentTransaction.createdAt),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 0.0,
                                  thickness: 2.0,
                                  color: Colors.amber.shade100,
                                ),
                                MovementMobileRow(
                                  currentTransaction: currentTransaction,
                                  rowColor: rowColor,
                                ),
                              ],
                            );
                          }
                        }
                        return MovementMobileRow(
                          currentTransaction: currentTransaction,
                          rowColor: rowColor,
                        );
                      },
                    ),
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

class MovementMobileRow extends StatelessWidget {
  const MovementMobileRow({
    super.key,
    required this.currentTransaction,
    required this.rowColor,
  });

  final ProductTransactionInDb currentTransaction;
  final Color rowColor;

  @override
  Widget build(BuildContext context) {
    final unitCost = NumberFormatter.convertFromCentsToDouble(currentTransaction.averageCost);
    final date = DateTimeTool.formatddMMyy(currentTransaction.createdAt);
    final time = DateTimeTool.formatHHmm(currentTransaction.createdAt);
    Widget icon = switch (currentTransaction.type) {
      (TransactionType.entry) => const Icon(
        FluentIcons.arrow_down_left_12_filled,
        color: Colors.blue,
        size: 16,
      ),
      (TransactionType.exit) => const Icon(
        FluentIcons.arrow_up_right_12_filled,
        color: Colors.red,
        size: 16,
      ),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.amber.shade100,
        onTap: () => showDocumentViewer(context, currentTransaction),
        child: Ink(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: rowColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    icon,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTransaction.subtype.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "#${currentTransaction.docNumber}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,

                child: Text(
                  unitCost.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,

                child: Column(
                  children: [
                    Text(
                      currentTransaction.quantity.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currentTransaction.resultStock.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
