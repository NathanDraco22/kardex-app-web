part of '../inventory_entry_screen.dart';

class InventoryEntryMobileScreen extends StatelessWidget {
  const InventoryEntryMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryEntryMediator.read(context);
    return Scaffold(
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final res = await showProductSearchDelegate(context);
            if (res == null) return;
            if (viewController.tableController.rows.length > 99) {
              if (!context.mounted) return;
              await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
              return;
            }
            if (!context.mounted) return;
            final unit = await showInventoryUnitPicker(context, res);
            if (unit == null) return;
            final newRow = ProductRow(
              product: res,
              quantity: 0,
              unitaryCost: (res is ProductInDbInBranch) ? (res.account.averageCost * unit.conversionFactor).round() : 0,
              editableCost: true,
              selectedUnitIndex: unit.unitIndex,
              conversionFactor: unit.conversionFactor,
              selectedUnitName: unit.unitName,
            );
            viewController.tableController.addRow(newRow);
          },
          label: const Text("Agregar Producto"),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final allFields = viewController.hasAllRequiredFields;
            if (!allFields) {
              context.pop();
              return;
            }
            final res = await DialogManager.confirmActionDialog(
              context,
              "Deseas salir sin guardar? (Perderas los cambios)",
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          "Entrada de Inventario",
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: EntryAppBarMenusButton(),
        ),
      ),
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.bottomLeft,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Text(
                  "Opciones de Navegacion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(FluentIcons.building_multiple_20_filled),
              title: const Text("Lista de Proveedores"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed("suppliers-catalog"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(FluentIcons.cube_12_filled),
              title: const Text("Lista Global de Productos"),
              onTap: () {
                context.pushNamed("product-list");
              },
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryEntryMediator.read(context);
    return Center(
      child: ListView(
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.only(bottom: 112, top: 8),
        children: [
          const _MobileHeaderSection(
            key: ValueKey("header"),
          ),
          const SizedBox(
            height: 12,
          ),
          Column(
            children: [
              InventoryMovementProductListView(
                controller: viewController.tableController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileHeaderSection extends StatefulWidget {
  const _MobileHeaderSection({super.key});

  @override
  State<_MobileHeaderSection> createState() => _MobileHeaderSectionState();
}

class _MobileHeaderSectionState extends State<_MobileHeaderSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewController = InventoryEntryMediator.watch(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Proveedor",
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                CustomAutocompleteTextfield<SupplierInDb>(
                  initValue: viewController.selectedSupplier,
                  onClose: (value) => viewController.selectedSupplier = value,
                  titleBuilder: (value) => value.name,
                  onSearch: (value) async {
                    final repo = context.read<SuppliersRepository>();
                    try {
                      final res = await repo.searchSupplierByKeyword(value);
                      return res;
                    } catch (e) {
                      return [];
                    }
                  },
                  suggestionBuilder: (value, close) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final supplier = value[index];
                        return ListTile(
                          title: Text(supplier.name),
                          onTap: () {
                            viewController.selectedSupplier = supplier;
                            close(supplier);
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: TitleTextField(
                        initialValue: viewController.docNumber,
                        title: "Documento",
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          viewController.docNumber = value;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          const Text("Fecha Doc"),
                          const SizedBox(height: 6),
                          DateFieldSelector(
                            initDate: viewController.docDate,
                            onSelectedDate: (value) {
                              viewController.docDate = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                  initialValue: viewController.observations,
                  onChanged: (value) {
                    viewController.observations = value;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
