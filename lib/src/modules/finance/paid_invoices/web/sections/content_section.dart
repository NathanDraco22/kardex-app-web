part of '../paid_invoices_web_screen.dart';

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
                      label: const Text("Fecha Liquidacion", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text("Factura", style: TextStyle(fontWeight: FontWeight.bold)), // Cambiado
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text("Costo", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text("Monto", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text("Utilidad"),
                      flex: 1,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentInvoice = invoices[index];
                    int totalCost = 0;
                    int totalSales = 0;

                    for (final item in currentInvoice.saleItems) {
                      totalCost += item.cost * item.quantity;
                      totalSales += item.total;
                    }
                    final totalPaidFormatted = NumberFormatter.convertToMoneyLike(totalSales);
                    final totalCostFormatted = NumberFormatter.convertToMoneyLike(totalCost);
                    final utility = NumberFormatter.convertToMoneyLike(
                      totalSales - totalCost,
                    );

                    final paidAtFormatted = DateTimeTool.formatddMMyy(currentInvoice.paidAt ?? DateTime.now());

                    return BasicTableRow(
                      color: rowColor,
                      onTap: () {
                        showInvoiceInspector(context, currentInvoice);
                      },
                      cells: [
                        BasicTableCell(
                          content: Text(paidAtFormatted),
                        ),
                        BasicTableCell(
                          content: Text(currentInvoice.docNumber),
                        ),
                        BasicTableCell(
                          content: Text(totalCostFormatted),
                        ),
                        BasicTableCell(
                          content: Text(totalPaidFormatted),
                        ),
                        BasicTableCell(
                          content: Text(utility),
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
