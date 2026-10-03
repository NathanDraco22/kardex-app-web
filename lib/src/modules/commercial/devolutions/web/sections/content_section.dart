part of '../devolutions_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDevolutionsCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadDevolutionsLoading || state is ReadDevolutionsLoadingMore) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                switch (state) {
                  case ReadDevolutionsInitial():
                    return const Center(
                      child: Text("Busca una factura por número o usa los filtros del día"),
                    );
                  case ReadDevolutionsLoading():
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ReadDevolutionsError():
                    return Center(
                      child: Text(state.message),
                    );
                  case ReadDevolutionsSearchResult():
                    final authCubit = getIt<AuthCubit>();
                    if (authCubit.state is! Authenticated) {
                      return const Center(
                        child: Text("No autenticado"),
                      );
                    }
                    final branch = (authCubit.state as Authenticated).branch;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: InvoiceViewerContent(
                          invoice: state.invoice,
                          branch: branch,
                        ),
                      ),
                    );
                  case ReadDevolutionsSuccess():
                    return _buildInvoicesTable(context, state.invoices);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable(BuildContext context, List<InvoiceInDb> invoices) {
    return BasicTableListView(
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
        BasicTableColumn(
          label: const Text(
            "Acciones",
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
        final totalPaid = NumberFormatter.convertFromCentsToUnitsCurrency(currentInvoice.amountPaid);

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
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(totalPaid),
                  Text(
                    _invoiceStatusLabel(currentInvoice.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            BasicTableCell(
              content: SecondaryMenuButton(
                onPressed: () async {
                  if (currentInvoice.clientId != kSaleClientId && currentInvoice.amountPaid > 0) {
                    DialogManager.showInfoDialog(context, "Los clientes de crédito con facturas abonadas no pueden hacer devoluciones de productos");
                    return;
                  }
                  final result = await context
                      .read<InvoicesRepository>()
                      .getInvoiceDevolutionById(currentInvoice.id);
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevolutionsSelectionScreen(
                        invoice: result.invoice,
                        devolutions: result.devolutions,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.file_open_rounded),
                label: const Text("Devolver"),
              ),
            ),
          ],
        );
      },
    );
  }

  String _invoiceStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return "Pagada";
      case InvoiceStatus.partiallypaid:
        return "Parcial";
      case InvoiceStatus.open:
        return "Sin pagar";
      case InvoiceStatus.draft:
        return "Borrador";
      case InvoiceStatus.cancelled:
        return "Cancelada";
    }
  }
}
