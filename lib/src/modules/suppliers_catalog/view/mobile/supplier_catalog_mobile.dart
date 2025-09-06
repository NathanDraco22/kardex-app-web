part of '../suppliers_catalog_screen.dart';

class SupplierCatalogMobile extends StatelessWidget {
  const SupplierCatalogMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

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

          return const _MobileBody();
        },
      ),
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
              child: MobileSuppliersTable(),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileSuppliersTable extends StatelessWidget {
  const MobileSuppliersTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadSupplierCubit>();
    final state = cubit.state as ReadSupplierSuccess;
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
                    onSearch: (value) => cubit.searchSupplierByKeyword(value),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ReadSupplierCubit, ReadSupplierState>(
            builder: (context, state) {
              if (state is! ReadSupplierSearching) return const SizedBox();
              return const LinearProgressIndicator();
            },
          ),

          const SizedBox(height: 12),
          const Divider(),

          Builder(
            builder: (context) {
              if (state.suppliers.isEmpty) {
                return const Center(
                  child: NoItemWidget(
                    icon: Icons.perm_contact_calendar_outlined,
                    text: "No hay Proveedores",
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: state.suppliers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currentSupplier = state.suppliers[index];

                    Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    if (state is HighlightedSupplier) {
                      if (state.updatedSuppliers.any((element) => element.id == currentSupplier.id)) {
                        rowColor = Colors.blue.shade100;
                      } else if (state.newSuppliers.any((element) => element.id == currentSupplier.id)) {
                        rowColor = Colors.yellow.shade200;
                      }
                    }
                    return MobileRow(
                      color: rowColor,
                      title: currentSupplier.name,
                      isActive: currentSupplier.isActive,
                      subtitle1: "RUC: ${currentSupplier.cardId}",
                      subtitle2: "Telf: ${currentSupplier.phone}",
                      onEditButtonPresesed: () async {
                        final res = await showCreateSupplierDialog(context, supplier: currentSupplier);

                        if (res == null) return;
                        if (!context.mounted) return;
                        await context.read<ReadSupplierCubit>().markSupplierUpdated(res);
                        if (!context.mounted) return;
                        context.read<ReadSupplierCubit>().refreshSupplier();
                      },
                      onTab: () {},
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
