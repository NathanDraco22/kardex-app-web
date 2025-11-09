part of '../devolution_history_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDevolutionHistoryCubit>();
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
                if (readCubit.state is ReadDevolutionHistoryLoading) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) {
                if (readCubit.state is! ReadDevolutionHistorySuccess) {
                  return const SizedBox.shrink();
                }
                final devolutions = (state as ReadDevolutionHistorySuccess).devolutions;
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
                          "Numero Devolución",
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
                    itemCount: devolutions.length,
                    rowBuilder: (context, index) {
                      final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                      final devolution = devolutions[index];
                      final devolutionDate = DateTimeTool.formatddMMyy(devolution.createdAt);
                      final devolutionTime = DateTimeTool.formatHHmm(devolution.createdAt);
                      final total = NumberFormatter.convertToMoneyLike(devolution.total);

                      return BasicTableRow(
                        color: rowColor,
                        onTap: () {
                          showDevolutionViewerDialog(context, devolution);
                        },
                        cells: [
                          BasicTableCell(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  devolutionDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  devolutionTime,
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
                              devolution.docNumber,
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
