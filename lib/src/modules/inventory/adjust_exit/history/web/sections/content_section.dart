part of '../adjust_exit_history_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadAdjustExitHistoryCubit>();
    final state = readCubit.state;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final maxScrollExtends = notification.metrics.maxScrollExtent;
        final scrollOffset = notification.metrics.pixels;
        final nextPageThreshold = maxScrollExtends * 0.65;

        if (scrollOffset >= nextPageThreshold) {
          readCubit.nextPage();
        }

        return false;
      },
      child: Card(
        child: Column(
          children: [
            Builder(
              builder: (context) {
                if (readCubit.state is ReadAdjustExitHistoryLoading) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) {
                if (readCubit.state is! ReadAdjustExitHistorySuccess) {
                  return const SizedBox.shrink();
                }
                final exits = (state as ReadAdjustExitHistorySuccess).exits;
                return Expanded(
                  child: BasicTableListView(
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
                          "Numero Documento",
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
                    ],
                    itemCount: exits.length,
                    rowBuilder: (context, index) {
                      final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                      final exit = exits[index];
                      // AdjustExitInDb only has createdAt (int epoch)
                      final exitDate = DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(exit.createdAt));
                      final exitTime = DateTimeTool.formatHHmm(DateTime.fromMillisecondsSinceEpoch(exit.createdAt));

                      // Calculate total since DB doesn't store it
                      // Using fold<int> since AdjustExitItem has int cost and quantity
                      final totalVal = exit.items.fold<int>(0, (prev, item) => prev + (item.cost * item.quantity));
                      final total = NumberFormatter.convertToMoneyLike(totalVal);

                      return BasicTableRow(
                        color: rowColor,
                        onTap: () {
                          showAdjustExitViewerDialog(context, exit);
                        },
                        cells: [
                          BasicTableCell(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exitDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  exitTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BasicTableCell(
                            content: Text(
                              exit.docNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          BasicTableCell(
                            content: Text(
                              total,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
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
      ),
    );
  }
}
