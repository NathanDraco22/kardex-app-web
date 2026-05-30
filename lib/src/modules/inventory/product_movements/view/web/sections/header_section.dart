part of '../product_movements_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  DateTime selectedDay = DateTime.now();
  ProductInDb? selectedProduct;
  TransactionType? selectedType;

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
                      branchId: getIt<AuthCubit>().currentBranchId,
                      product: selectedProduct!,
                      queryParams: TransactionQueryParams(
                        endDate: selectedDay.endOfDay().millisecondsSinceEpoch,
                        type: selectedType?.name,
                      ),
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
                        branchId: getIt<AuthCubit>().currentBranchId,
                        product: selectedProduct!,
                        queryParams: TransactionQueryParams(
                          endDate: selectedDay.endOfDay().millisecondsSinceEpoch,
                          type: selectedType?.name,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<TransactionType?>(
              segments: const [
                ButtonSegment(
                  value: null,
                  label: Text("Todas"),
                ),
                ButtonSegment(
                  value: TransactionType.entry,
                  label: Text("Entradas"),
                ),
                ButtonSegment(
                  value: TransactionType.exit,
                  label: Text("Salidas"),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  selectedType = newSelection.first;
                });
                if (selectedProduct == null) return;
                readCubit.loadPaginatedTransactions(
                  branchId: getIt<AuthCubit>().currentBranchId,
                  product: selectedProduct!,
                  queryParams: TransactionQueryParams(
                    endDate: selectedDay.endOfDay().millisecondsSinceEpoch,
                    type: selectedType?.name,
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
