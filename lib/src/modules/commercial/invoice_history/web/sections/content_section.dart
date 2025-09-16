part of '../invoice_history_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoiceCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (readCubit.state is ReadInvoiceLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (readCubit.state is! ReadInvoiceSuccess) {
                return const SizedBox.shrink();
              }
              final invoices = (state as ReadInvoiceSuccess).invoices;
              return Expanded(
                child: BasicTableListView(
                  columns: [
                    BasicTableColumn(
                      label: const Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text("Numero Facture", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                  ],
                  itemCount: invoices.length,
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final invoice = invoices[index];
                    final invoiceDate = DateTimeTool.formatddMMyyyy(invoice.createdAt);
                    final total = NumberFormatter.convertToMoneyLike(invoice.total);

                    return BasicTableRow(
                      color: rowColor,
                      cells: [
                        BasicTableCell(content: Text(invoiceDate)),
                        BasicTableCell(content: Text(invoice.docNumber)),
                        BasicTableCell(content: Text(total)),
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
