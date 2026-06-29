part of '../history_entry_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadEntryHistoryCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadEntryHistoryFiltering || state is ReadEntryHistoryLoading) {
                return const LinearProgressIndicator();
              }

              return const SizedBox.shrink();
            },
          ),

          Builder(
            builder: (context) {
              if (state is! ReadEntryHistorySuccess) {
                return const SizedBox.shrink();
              }

              final entryHistories = state.histories;

              return Expanded(
                child: BasicTableListView(
                  itemCount: entryHistories.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text(
                        "Fecha",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Proveedor",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Documento",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(label: const Text(""), flex: 1),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentEntryHistory = entryHistories[index];
                    final currentDocDate = DateTimeTool.formatddMMyy(currentEntryHistory.docDate);
                    final totalInMoney = NumberFormatter.convertToMoneyLike(currentEntryHistory.total);

                    return BasicTableRow(
                      onTap: () {
                        showEntryHistoryViewerDialog(context, currentEntryHistory);
                      },
                      color: rowColor,
                      cells: [
                        BasicTableCell(
                          content: Text(currentDocDate),
                        ),
                        BasicTableCell(
                          content: Text(
                            currentEntryHistory.supplier.name,
                          ),
                        ),
                        BasicTableCell(
                          content: Text(currentEntryHistory.docNumber),
                        ),
                        BasicTableCell(
                          content: Text(totalInMoney),
                        ),
                        BasicTableCell(
                          content: const SizedBox.shrink(),
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
