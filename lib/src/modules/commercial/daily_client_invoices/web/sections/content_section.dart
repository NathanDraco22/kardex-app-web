part of '../daily_client_invoices_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDailyClientInvoicesCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadDailyClientInvoicesLoading || state is ReadDailyClientInvoicesLoadingMore) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadDailyClientInvoicesSuccess) {
                return const SizedBox.shrink();
              }

              final invoices = state.invoices;

              return Expanded(
                child: BasicTableListView(
                  itemCount: invoices.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text(
                        "Hora/Fecha",
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
                        "Cliente",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      flex: 2,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Monto pagado",
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

                    final paidDate = currentInvoice.paidAt ?? DateTime.now();
                    final paidAtFormatted = "${DateTimeTool.formatddMMyy(paidDate)} ${DateTimeTool.formatHHmm(paidDate)}";

                    final clientName = currentInvoice.clientInfo.name;

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
                          content: Text(
                            clientName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
