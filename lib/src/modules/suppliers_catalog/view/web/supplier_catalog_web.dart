part of '../suppliers_catalog_screen.dart';

class SuppliersCatalogWeb extends StatelessWidget {
  const SuppliersCatalogWeb({super.key});

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
      appBar: AppBar(title: const Text("Lista de Proveedores")),
      body: BlocBuilder<ReadSupplierCubit, ReadSupplierState>(
        builder: (context, state) {
          if (state is ReadSupplierLoading || state is ReadSupplierInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SupplierReadError) {
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
                      final res = await showCreateSupplierDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadSupplierCubit>().putSupplierFirst(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Proveedor"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: SuppliersTable(),
            ),
          ],
        ),
      ),
    );
  }
}
