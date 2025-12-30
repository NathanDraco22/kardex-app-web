part of '../../inventory_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryEntryMediator.read(context)!;
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
                            mediator.refresh();
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
                                mediator.refresh();
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
                          Flexible(
                            child: SizedBox.expand(),
                          ),
                          Flexible(
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
    final mediator = InventoryEntryMediator.watch(context)!;

    final isDisabled = !mediator.hasAllRequiredFields();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isDisabled ? null : () => saveAction(context),
          icon: const Icon(Icons.save),
          label: const Text("Guardar"),
        ),
      ],
    );
  }
}

Future<void> saveAction(BuildContext context) async {
  final mediator = InventoryEntryMediator.read(context)!;
  if (!mediator.hasAllRequiredFields()) return;
  final headerData = mediator.headerData;
  final productTableController = mediator.productTableController;
  if (mediator.hasProductWithZeroValue()) {
    await DialogManager.showErrorDialog(context, "No se pueden guardar productos con valor 0");
    return;
  }

  final res = await DialogManager.slideToConfirmActionDialog(
    context,
    "Deseas Guardar el Documento? (No se puede deshacer)",
  );

  if (res != true) return;

  final items = productTableController.rows.map((e) {
    return EntryItem(
      productId: e.product.id,
      productName: e.product.name,
      quantity: e.quantity,
      cost: e.unitaryCost,
      code: e.product.code,
      brandName: e.product.brandName,
      unitName: e.product.unitName,
      expirationDate: e.expirationDate?.millisecondsSinceEpoch,
    );
  }).toList();

  if (!context.mounted) return;

  final (currentUser, _) = SessionTool.getFullUserFrom(context);

  final createEntryDoct = CreateEntryDoc(
    supplierId: headerData.supplier!.id,
    docNumber: headerData.docNumber!,
    docDate: headerData.docDate!,
    branchId: BranchesTool.getCurrentBranchId(),
    items: items,
    createdBy: UserInfo(
      id: currentUser.id,
      name: currentUser.username,
    ),
  );
  context.read<WriteEntryDocCubit>().createNewEntryDoc(createEntryDoct);
}
