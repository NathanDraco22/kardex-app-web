part of '../commercial_product_movements_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  DateTime selectedDay = DateTime.now();
  ProductInDb? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadProductTransactionCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    selectedProduct = await showSearchProductDialog(context);
                    if (selectedProduct == null) return;

                    readCubit.loadPaginatedTransactions(
                      product: selectedProduct!,
                      endDate: selectedDay,
                    );
                  },
                  label: const Text("Buscar Producto"),
                  icon: const Icon(Icons.search),
                ),

                SizedBox(
                  width: 150,
                  child: DatePickerListTile(
                    defaultDate: selectedDay,
                    title: "Fecha",
                    onSelected: (value) {
                      selectedDay = value;
                      if (selectedProduct == null) return;
                      readCubit.loadPaginatedTransactions(
                        product: selectedProduct!,
                        endDate: selectedDay,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
