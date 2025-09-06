part of '../product_list_screen.dart';

class ProductListScreenMobile extends StatelessWidget {
  const ProductListScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadProductCubit>();

    if (readCubit.state is ReadProductInitial || readCubit.state is ReadProductLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (readCubit.state is ProductReadError) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lista de Productos")),
        body: Center(
          child: Text((readCubit.state as ProductReadError).message),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Productos")),
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateProductDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadProductCubit>().putProductFirst(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Producto"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Expanded(child: MobileProductsTable()),
          ],
        ),
      ),
    );
  }
}

class MobileProductsTable extends StatelessWidget {
  const MobileProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadProductCubit>();
    final state = readCubit.state as ReadProductSuccess;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: SearchFieldDebounced(
                    onSearch: (value) => readCubit.searchProductByKeyword(value),
                  ),
                ),
              ],
            ),
          ),

          if (state is ReadProductSearching) const LinearProgressIndicator(),

          const SizedBox(height: 12),
          const Divider(),

          Builder(
            builder: (context) {
              if (state.products.isEmpty) {
                return const Center(
                  child: NoItemWidget(
                    icon: Icons.list,
                    text: "No hay productos",
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final currentProduct = state.products[index];

                    Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    if (state is HighlightedProduct) {
                      if (state.updatedProducts.any((element) => element.id == currentProduct.id)) {
                        rowColor = Colors.blue.shade100;
                      } else if (state.newProducts.any((element) => element.id == currentProduct.id)) {
                        rowColor = Colors.yellow.shade200;
                      }
                    }

                    return MobileRow(
                      title: currentProduct.name,
                      color: rowColor,
                      isActive: currentProduct.isActive,
                      subtitle1: currentProduct.brandName,
                      subtitle2: currentProduct.unitName,
                      onEditButtonPresesed: () async {
                        final res = await showCreateProductDialog(context, product: currentProduct);

                        if (res == null) return;
                        if (!context.mounted) return;
                        await readCubit.markProductUpdated(res);
                      },
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
