part of '../history_exit_screen_mobile.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadExitHistoryCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              // Cambiado a los estados de ExitHistory
              if (state is ReadExitHistoryLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              // Cambiado a ReadExitHistorySuccess
              if (state is! ReadExitHistorySuccess) {
                return const SizedBox.shrink();
              }

              final exitHistories = state.histories;

              return Expanded(
                child: BasicTableListView(
                  itemCount: exitHistories.length,
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
                        "Cliente",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ), // Cambiado
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      flex: 1,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentExitHistory = exitHistories[index];
                    final currentDocDate = DateTimeTool.formatddMMyy(currentExitHistory.docDate);
                    final totalInMoney = NumberFormatter.convertToMoneyLike(currentExitHistory.total);

                    return BasicTableRow(
                      color: rowColor,
                      onTap: () {
                        showExitHistoryViewerDialog(context, currentExitHistory);
                      },
                      cells: [
                        BasicTableCell(
                          content: Text(currentDocDate),
                        ),
                        BasicTableCell(
                          content: Text(currentExitHistory.client.name),
                        ),
                        BasicTableCell(
                          content: Text(currentExitHistory.docNumber),
                        ),
                        BasicTableCell(
                          content: Text(
                            totalInMoney,
                            textAlign: TextAlign.center,
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
