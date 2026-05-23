part of '../invoice_by_product_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  final ProductInDb? selectedProduct;
  final ValueChanged<ProductInDb?> onProductSelected;

  const _HeaderSection({
    required this.selectedProduct,
    required this.onProductSelected,
  });

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoiceByProductCubit>();

    return Card(
      key: ValueKey(readCubit.params),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      readCubit.setDefaultParams();
                      widget.onProductSelected(null);
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar Filtros"),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("start_date_${readCubit.params.startDate.hashCode}"),
                      defaultDate: readCubit.params.startDate,
                      title: "Fecha Inicio",
                      onSelected: (value) {
                        readCubit.params.startDate = value;
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("end_date_${readCubit.params.endDate.hashCode}"),
                      defaultDate: readCubit.params.endDate,
                      title: "Fecha Fin",
                      onSelected: (value) {
                        readCubit.params.endDate = value.endOfDay();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () async {
                      final product = await showProductSearchDelegate(context);
                      if (product == null) return;
                      widget.onProductSelected(product);
                    },
                    label: widget.selectedProduct == null
                        ? const Text("Seleccionar Producto")
                        : const Text("Cambiar Producto"),
                  ),
                  FilledButton.icon(
                    onPressed: widget.selectedProduct == null
                        ? null
                        : () {
                            readCubit.loadInvoicesByProduct(widget.selectedProduct!.id);
                          },
                    label: const Text("Filtrar"),
                    icon: const Icon(Icons.filter_alt_rounded),
                  ),
                ],
              ),
            ),
            if (widget.selectedProduct != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DisplayProductCode(product: widget.selectedProduct!),
                    const SizedBox(height: 4),
                    Row(
                      spacing: 8,
                      children: [
                        Text(
                          widget.selectedProduct!.brandName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.selectedProduct!.unitName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
