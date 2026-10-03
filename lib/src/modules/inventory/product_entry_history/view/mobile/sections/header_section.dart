part of '../product_entry_history_screen_mobile.dart';

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
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SecondaryMenuButton(
              onPressed: () async {
                selectedProduct = await showProductSearchDelegate(context);
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
