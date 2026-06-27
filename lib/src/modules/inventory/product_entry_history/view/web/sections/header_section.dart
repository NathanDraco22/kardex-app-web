part of '../product_entry_history_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  ProductInDb? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadProductEntryHistoryCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () async {
                selectedProduct = await showSearchProductDialog(context);
                if (selectedProduct == null) return;
                readCubit.loadEntryHistory(product: selectedProduct!);
              },
              label: const Text("Buscar Producto"),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}
