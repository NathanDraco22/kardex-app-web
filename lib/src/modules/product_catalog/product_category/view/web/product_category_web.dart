part of '../product_category_screen.dart';

class ProductCategoryWeb extends StatelessWidget {
  const ProductCategoryWeb({super.key});

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
      appBar: AppBar(title: const Text("Lista de Categorias de productos")),
      body: BlocBuilder<ReadProductCategoryCubit, ReadProductCategoryState>(
        builder: (context, state) {
          if (state is ReadProductCategoryLoading || state is ReadProductCategoryInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProductCategoryReadError) {
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
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade600,
                ),
                Flexible(
                  child: Text(
                    "Las Categorias de Productos no pueden ser eliminadas",
                    maxLines: 2,
                    style: TextStyle(color: Colors.amber.shade600, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateProductCategoryDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadProductCategoryCubit>().putProductCategoryFirst(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Categoria de Producto"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: ProductCategoryTable(),
            ),
          ],
        ),
      ),
    );
  }
}
