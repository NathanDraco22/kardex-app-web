part of '../adjust_entry_history_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadAdjustEntryHistoryCubit>();
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
                if (readCubit.state is ReadAdjustEntryHistoryLoading) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) {
                if (readCubit.state is! ReadAdjustEntryHistorySuccess) {
                  return const SizedBox.shrink();
                }
                final entries = (state as ReadAdjustEntryHistorySuccess).entries;
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
                    itemCount: entries.length,
                    rowBuilder: (context, index) {
                      final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                      final entry = entries[index];
                      // AdjustEntryInDb only has createdAt (int epoch)
                      final entryDate = DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(entry.createdAt));
                      final entryTime = DateTimeTool.formatHHmm(DateTime.fromMillisecondsSinceEpoch(entry.createdAt));

                      // Calculate total since DB doesn't store it
                      final totalVal = entry.items.fold<int>(0, (prev, item) => prev + (item.cost * item.quantity));
                      final total = NumberFormatter.convertToMoneyLike(totalVal);

                      return BasicTableRow(
                        color: rowColor,
                        onTap: () {
                          showAdjustEntryViewerDialog(context, entry);
                        },
                        cells: [
                          BasicTableCell(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entryDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  entryTime,
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
                              entry.docNumber,
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
