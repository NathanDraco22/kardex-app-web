part of '../receipt_history_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadReceiptHistoryCubit>();
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
                if (readCubit.state is ReadReceiptHistoryLoading) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) {
                if (readCubit.state is! ReadReceiptHistorySuccess) {
                  return const SizedBox.shrink();
                }
                final receipts = (state as ReadReceiptHistorySuccess).receipts;
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
                          "Numero Recibo",
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
                    itemCount: receipts.length,
                    rowBuilder: (context, index) {
                      final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                      final receipt = receipts[index];
                      final receiptDate = DateTimeTool.formatddMMyy(receipt.createdAt);
                      final receiptTime = DateTimeTool.formatHHmm(receipt.createdAt);
                      final total = NumberFormatter.convertToMoneyLike(receipt.total);

                      return BasicTableRow(
                        color: rowColor,
                        onTap: () {
                          showReceiptViewerDialog(context, receipt);
                        },
                        cells: [
                          BasicTableCell(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receiptDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  receiptTime,
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
                              receipt.docNumber,
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
