part of '../invoice_by_product_web_screen.dart';

class _ContentSection extends StatelessWidget {
  final ProductInDb? selectedProduct;

  const _ContentSection({
    required this.selectedProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedProduct == null) {
      return const Card(
        child: Center(
          child: NoItemWidget(
            icon: Icons.shopping_bag_outlined,
            text: "Por favor seleccione un producto para ver sus ventas",
          ),
        ),
      );
    }

    final state = context.watch<ReadInvoiceByProductCubit>().state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadInvoiceByProductLoading ||
                  state is FetchingNextPageInvoiceByProduct) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          if (state is ReadInvoiceByProductLoadMoreError)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "No se pudieron cargar más facturas: ${state.message}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<ReadInvoiceByProductCubit>().nextPage();
                    },
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            ),
          Builder(
            builder: (context) {
              if (state is ReadInvoiceByProductError) {
                return Expanded(
                  child: Center(
                    child: Text(
                      "Error al cargar las facturas: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (state is ReadInvoiceByProductInitial) {
                return const Expanded(
                  child: Center(
                    child: NoItemWidget(
                      icon: Icons.filter_alt_rounded,
                      text: "Presione Filtrar para consultar las ventas de este producto",
                    ),
                  ),
                );
              }

              if (state is! ReadInvoiceByProductSuccess) {
                return const SizedBox.shrink();
              }

              final invoices = state.invoices;

              if (invoices.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: NoItemWidget(
                      icon: Icons.find_in_page_rounded,
                      text: "No se encontraron facturas para este producto en los filtros seleccionados",
                    ),
                  ),
                );
              }

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
                      label: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Cant. Vendida",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      flex: 1,
                    ),
                    BasicTableColumn(
                      label: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Importe",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = RowColorTool.getRowColor(index);
                    final currentInvoice = invoices[index];
                    final productLine = currentInvoice.productLine(selectedProduct!.id);

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
                          content: Align(
                            alignment: Alignment.center,
                            child: Text(productLine.quantityText),
                          ),
                        ),
                        BasicTableCell(
                          content: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              NumberFormatter.convertFromCentsToUnitsCurrency(productLine.total),
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
    );
  }
}
