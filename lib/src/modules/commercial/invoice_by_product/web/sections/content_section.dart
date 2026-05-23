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
            text: "Por favor seleccione un producto para ver sus facturas",
          ),
        ),
      );
    }

    final readCubit = context.watch<ReadInvoiceByProductCubit>();
    final state = readCubit.state;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final limit = notification.metrics.maxScrollExtent * 0.6;
        final currentPos = notification.metrics.pixels;

        if (currentPos > limit) {
          readCubit.nextPage();
        }
        return true;
      },
      child: Card(
        child: Column(
          children: [
            Builder(
              builder: (context) {
                if (state is ReadInvoiceByProductLoading || state is FetchingNextPageInvoiceByProduct) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
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

                if (state is! ReadInvoiceByProductSuccess) {
                  return const SizedBox.shrink();
                }

                final invoices = state.invoices;

                if (invoices.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: NoItemWidget(
                        icon: Icons.find_in_page_rounded,
                        text: "No se encontraron facturas para este producto en el rango seleccionado",
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
                        label: const Text(
                          "Cant. Vendida",
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

                      // Buscar el SaleItem específico para el producto seleccionado
                      final saleItem = currentInvoice.saleItems.firstWhere(
                        (item) => item.product.id == selectedProduct!.id,
                        orElse: () => SaleItem(
                          product: ProductItem(
                            id: selectedProduct!.id,
                            name: selectedProduct!.name,
                            unitName: selectedProduct!.unitName,
                            brandName: selectedProduct!.brandName,
                            code: selectedProduct!.code,
                          ),
                          selectedPrice: 0,
                          quantity: 0,
                          cost: 0,
                          price: 0,
                          subTotal: 0,
                          total: 0,
                        ),
                      );

                      final createdAt = currentInvoice.createdAt;
                      final clientName = currentInvoice.clientInfo.name;

                      final String qtyText;
                      if (saleItem.bonQuantity > 0) {
                        qtyText = "${saleItem.quantity} + ${saleItem.bonQuantity}";
                      } else {
                        qtyText = "${saleItem.quantity}";
                      }

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
                            content: Text(qtyText),
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
