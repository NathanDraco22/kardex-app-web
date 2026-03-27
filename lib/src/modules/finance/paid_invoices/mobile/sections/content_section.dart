part of '../paid_invoices_mobile_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadPaidInvoicesCubit>();
    final state = readCubit.state;
    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadPaidInvoicesLoading || state is ReadSearchingInvoice) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is! ReadPaidInvoicesSuccess) {
                return const SizedBox.shrink();
              }

              final invoices = state.invoices;

              return Expanded(
                child: BasicTableListView(
                  itemCount: invoices.length,
                  columns: [
                    BasicTableColumn(
                      label: const Text(
                        "Fecha Liquidacion",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Factura",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Costo",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Monto",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text(
                        "Utilidad",
                        textAlign: TextAlign.center,
                      ),
                      flex: 1,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentInvoice = invoices[index];
                    final totalPaid = NumberFormatter.convertFromCentsToDouble(currentInvoice.total);
                    final totalCost = NumberFormatter.convertFromCentsToDouble(currentInvoice.totalCost);
                    final utility = NumberFormatter.convertFromCentsToDouble(
                      currentInvoice.total - currentInvoice.totalCost,
                    );

                    final paidAtFormatted = DateTimeTool.formatddMMyy(currentInvoice.paidAt ?? DateTime.now());

                    return BasicTableRow(
                      color: rowColor,
                      onTap: () {
                        showInvoiceInspector(context, currentInvoice);
                      },
                      cells: [
                        BasicTableCell(
                          content: Text(
                            paidAtFormatted,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        BasicTableCell(
                          content: Text(
                            currentInvoice.docNumber,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        BasicTableCell(
                          content: Text(
                            totalCost.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        BasicTableCell(
                          content: Text(
                            totalPaid.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        BasicTableCell(
                          content: Text(
                            utility.toString(),
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
