part of '../product_list_screen.dart';

class ProductListScreenWeb extends StatelessWidget {
  const ProductListScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebScaffold();
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Productos")),
      body: BlocBuilder<ReadProductCubit, ReadProductState>(
        builder: (context, state) {
          if (state is ReadProductLoading || state is ReadProductInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProductReadError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const _WebBody();
        },
      ),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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

            const Expanded(
              child: ProductsTable(),
            ),
          ],
        ),
      ),
    );
  }
}
