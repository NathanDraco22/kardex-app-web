part of '../current_tranfers_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadTransfersCubit>();
    final state = cubit.state;
    final filterType = cubit.currentFilterType;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadTransfersLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadTransfersSuccess) {
                if (state is ReadTransfersError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return const SizedBox.shrink();
              }

              final transfers = state.transfers;

              if (transfers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No hay transferencias"),
                  ),
                );
              }

              final isSent = filterType == TransferFilterType.sent;
              final branchColumnTitle = isSent ? "Destino" : "Origen";

              return Expanded(
                child: BasicTableListView(
                  itemCount: transfers.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: Text(branchColumnTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                      flex: 2,
                    ),
                    BasicTableColumn(
                      label: const Text("Doc", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),

                    BasicTableColumn(
                      label: const Text("Estado", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final transfer = transfers[index];
                    final date = DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(transfer.createdAt));

                    final branchId = isSent ? transfer.destination : transfer.origin;
                    String branchName;
                    try {
                      branchName = BranchesTool.getBranchById(branchId).name;
                    } catch (_) {
                      branchName = "Desconocido ($branchId)";
                    }

                    Color rowColor = index.isEven ? Colors.grey.shade200 : Colors.white;

                    return BasicTableRow(
                      color: rowColor,
                      onTap: () async {
                        await showTransferDetailScreen(context, transfer);
                        if (context.mounted) {
                          cubit.loadPaginatedTransfers();
                        }
                      },
                      cells: [
                        BasicTableCell(content: Text(date)),
                        BasicTableCell(content: Text(branchName)),

                        BasicTableCell(content: Text(transfer.docNumber)),
                        BasicTableCell(
                          content: TranferStatusBadge(
                            status: transfer.status,
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
