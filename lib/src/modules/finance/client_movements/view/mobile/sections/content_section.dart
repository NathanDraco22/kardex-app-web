part of '../client_movements_screen_mobile.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadClientTransactionCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder(
          bloc: readCubit,
          builder: (context, state) {
            if (state is ReadClientTransactionInitial) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 80,
                      color: Colors.grey,
                    ),
                    Text(
                      "Busca un cliente",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ReadClientTransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReadClientTransactionError) {
              return Center(child: Text(state.message));
            }

            state as ReadClientTransactionSuccess;

            final currentClient = state.client;

            return Column(
              children: [
                Row(
                  children: [
                    Text(
                      currentClient.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    if (currentClient.cardId != null) Text("RFC: ${currentClient.cardId}"),
                    if (currentClient.phone != null) Text("Tel: ${currentClient.phone}"),
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
                          "Monto",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Saldo",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
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
