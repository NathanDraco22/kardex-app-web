part of "../price_to_product_screen.dart";

class PriceToProductWeb extends StatelessWidget {
  const PriceToProductWeb({super.key});

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
      appBar: AppBar(title: const Text("Precios por Producto")),
      body: BlocBuilder<ReadProductPriceCubit, ReadProductPriceState>(
        builder: (context, state) {
          if (state is ReadProductPriceLoading || state is ReadProductPriceInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProductPriceReadError) {
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
    final cubit = context.watch<ReadProductPriceCubit>();
    final state = cubit.state as ReadProductPriceSuccess;
    final productPrices = state.productPrices;

    return Center(
      child: Padding(
        padding: const EdgeInsetsGeometry.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade600,
                ),
                Text(
                  "Los Precios no pueden ser modificados",
                  style: TextStyle(color: Colors.amber.shade600, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateProductPriceDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadProductPriceCubit>().refreshProductPrice();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Precio"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ...List.generate(
                    productPrices.length,
                    (index) {
                      final productPrice = productPrices[index];
                      return ListTile(
                        title: Text(productPrice.name),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
