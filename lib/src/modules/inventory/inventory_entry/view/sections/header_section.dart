part of '../inventory_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryEntryMediator.of(context)!;
    final headerData = mediator.headerData;
    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Card(
            margin: EdgeInsets.zero,

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        titleBuilder: (value) => value.name,
                        onSearch: (value) async {
                          final repo = context.read<SuppliersRepository>();
                          final res = await repo.searchSupplierByKeyword(value);
                          return res;
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
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: TitleTextField(
                          title: "Documento",
                          onChanged: (value) {
                            headerData.docNumber = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          children: [
                            const Text("Fecha Doc"),
                            const SizedBox(height: 6),
                            DateFieldSelector(
                              onSelectedDate: (value) {
                                headerData.docDate = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        Flexible(
          fit: FlexFit.tight,
          child: Card(
            margin: EdgeInsets.zero,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Flexible(
                      child: Row(
                        children: [
                          const Flexible(
                            child: SizedBox.expand(),
                          ),
                          const Flexible(
                            child: MenuActions(),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: FractionallySizedBox(
                              heightFactor: 1.0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: TitleTextField(
                                  title: "Observaciones",
                                  maxLines: 2,
                                  onChanged: (p0) {
                                    headerData.observations = p0;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Flexible(
                            child: SizedBox.expand(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuActions extends StatelessWidget {
  const MenuActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final configState = context.read<ConfigAppCubit>().state;
    final mediator = InventoryEntryMediator.of(context)!;
    final headerData = mediator.headerData;
    final productTableController = mediator.productTableController;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final items = productTableController.rows.map((e) {
              return EntryItem(
                productId: e.product.id,
                quantity: e.quantity,
                cost: e.unitaryCost,
              );
            }).toList();

            final createEntryDoct = CreateEntryDoc(
              supplierId: headerData.supplier!.id,
              docNumber: headerData.docNumber!,
              docDate: headerData.docDate!,
              branchId: configState.currentBranch,
              items: items,
            );

            context.read<WriteEntryDocCubit>().createNewEntryDoc(createEntryDoct);
          },
          icon: const Icon(Icons.save),
          label: const Text("Guardar"),
        ),
      ],
    );
  }
}
