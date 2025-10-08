part of '../daily_invoices_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDailyAnonInvoicesCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadDailyAnonInvoicesLoading || state is ReadSearchingInvoice) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadDailyAnonInvoicesSuccess) {
                return const SizedBox.shrink();
              }

              final invoices = state.invoices;

              return Expanded(
                child: BasicTableListView(
                  itemCount: invoices.length,
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
                        "Factura",
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

                    final currentInvoice = invoices[index];
                    final totalPaid = NumberFormatter.convertToMoneyLike(currentInvoice.total);

                    final paidAtFormatted = DateTimeTool.formatHHmm(
                      currentInvoice.paidAt ?? DateTime.now(),
                    );

                    return BasicTableRow(
                      onTap: () {
                        showInvoiceViewerDialog(context, currentInvoice);
                      },
                      color: rowColor,
                      cells: [
                        BasicTableCell(
                          content: Text(paidAtFormatted),
                        ),
                        BasicTableCell(
                          content: Text("#${currentInvoice.docNumber}"),
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
