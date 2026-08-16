part of '../../inventory_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryEntryMediator.watch(context);
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: TitleTextField(
                          title: "Documento",
                          initialValue: viewController.docNumber,
                          onChanged: (value) {
                            viewController.docNumber = value;
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
                                  initialValue: viewController.observations,
                                  onChanged: (value) {
                                    viewController.observations = value;
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
    final viewController = InventoryEntryMediator.watch(context);

    final isDisabled = !viewController.hasAllRequiredFields;

    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedCtrlButton(
          hotKey: "4",
          onPressed: () async {
            await context.pushNamed("suppliers-catalog");
          },
          icon: FluentIcons.building_multiple_20_filled,
          label: "Proveedores",
        ),
        ElevatedCtrlButton(
          hotKey: "5",
          onPressed: () async {
            await context.pushNamed("product-list");
          },
          icon: FluentIcons.cube_12_filled,
          label: "Productos",
        ),
        const Spacer(),
        ElevatedCtrlButton(
          hotKey: "G",
          onPressed: isDisabled ? null : () => saveAction(context),
          icon: Icons.save,
          label: "Guardar",
        ),
      ],
    );
  }
}

Future<void> saveAction(BuildContext context) async {
  final viewController = InventoryEntryMediator.read(context);
  if (!viewController.hasAllRequiredFields) return;
  if (viewController.hasProductWithZeroValue) {
    await DialogManager.showErrorDialog(context, "No se pueden guardar productos con valor 0");
    return;
  }

  final res = await DialogManager.slideToConfirmActionDialog(
    context,
    "Deseas Guardar el Documento? (No se puede deshacer)",
  );

  if (res != true) return;

  final createEntryDoc = viewController.generateCreateEntryDoc();
  if (createEntryDoc == null) return;

  if (!context.mounted) return;
  context.read<WriteEntryDocCubit>().createNewEntryDoc(createEntryDoc);
}
