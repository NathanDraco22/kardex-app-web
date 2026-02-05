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
    final mediator = InventoryEntryMediator.read(context)!;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final res = await showProductSearchDelegate(context);
            if (res == null) return;
            if (mediator.productListViewController.rowCards.length > 99) {
              if (!context.mounted) return;
              await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
              return;
            }
            final newRow = ProductRowCard(
              product: res,
              quantity: 0,
              unitaryCost: 0,
              editableCost: true,
            );
            mediator.productListViewController.addRowCard(newRow);
            mediator.refresh();
          },
          label: const Text("Agregar Producto"),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final allFields = mediator.hasMobileAllRequiredFields();
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
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryEntryMediator.read(context)!;
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
                controller: mediator.productListViewController,
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
    final mediator = InventoryEntryMediator.read(context)!;
    final headerData = mediator.headerData;
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
                  initValue: headerData.supplier,
                  onClose: (value) => headerData.supplier = value,
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
                            headerData.supplier = supplier;
                            close(supplier);
                            mediator.refresh();
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
                        initialValue: headerData.docNumber,
                        title: "Documento",
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          headerData.docNumber = value;
                          mediator.refresh();
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
                            initDate: headerData.docDate,
                            onSelectedDate: (value) {
                              headerData.docDate = value;
                              mediator.refresh();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
