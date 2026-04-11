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
                    final totalPaid = NumberFormatter.convertFromCentsToUnitsCurrency(currentInvoice.total);

                    final createdAt = currentInvoice.createdAt;
                    final clientName = currentInvoice.clientInfo.name;

                    return BasicTableRow(
                      onTap: () {
                        showInvoiceViewerDialog(context, currentInvoice);
                      },
                      color: rowColor,
                      cells: [
                        BasicTableCell(
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateTimeTool.formatddMMyy(createdAt)),
                              Text(DateTimeTool.formatHHmm(createdAt)),
                            ],
                          ),
                        ),
                        BasicTableCell(
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("#${currentInvoice.docNumber}"),
                              Text(
                                clientName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
