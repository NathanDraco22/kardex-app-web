part of '../invoice_history_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoiceHistoryCubit>();
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
                if (readCubit.state is ReadInvoiceHistoryLoading) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            Builder(
              builder: (context) {
                if (readCubit.state is! ReadInvoiceHistorySuccess) {
                  return const SizedBox.shrink();
                }
                final invoices = (state as ReadInvoiceHistorySuccess).invoices;
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
                          "Numero Factura",
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
                    itemCount: invoices.length,
                    rowBuilder: (context, index) {
                      final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                      final invoice = invoices[index];
                      final invoiceDate = DateTimeTool.formatddMMyy(invoice.createdAt);
                      final invoiceTime = DateTimeTool.formatHHmm(invoice.createdAt);
                      final total = NumberFormatter.convertToMoneyLike(invoice.total);

                      return BasicTableRow(
                        color: rowColor,
                        onTap: () {
                          showInvoiceViewerDialog(context, invoice);
                        },
                        cells: [
                          BasicTableCell(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invoiceDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  invoiceTime,
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
                              invoice.docNumber,
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
