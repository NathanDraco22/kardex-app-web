part of '../daily_receipt_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDailyReceiptsCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadDailyReceiptsLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadDailyReceiptsSuccess) {
                return const SizedBox.shrink();
              }

              final receipts = state.receipts;

              return Expanded(
                child: BasicTableListView(
                  itemCount: receipts.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text(
                        "Hora",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Recibo",
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
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Monto",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentReceipt = receipts[index];
                    final totalPaid = NumberFormatter.convertToMoneyLike(currentReceipt.total);

                    final paidAtFormatted = DateTimeTool.formatHHmm(
                      currentReceipt.createdAt,
                    );

                    return BasicTableRow(
                      onTap: () {
                        showReceiptViewerDialog(context, currentReceipt);
                        // showInvoiceViewerDialog(context, currentReceipt);
                      },
                      color: rowColor,
                      cells: [
                        BasicTableCell(
                          content: Text(paidAtFormatted),
                        ),
                        BasicTableCell(
                          content: Text("#${currentReceipt.docNumber}"),
                        ),
                        BasicTableCell(
                          content: Text(currentReceipt.clientInfo.name),
                        ),

                        BasicTableCell(
                          content: Text(totalPaid),
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
