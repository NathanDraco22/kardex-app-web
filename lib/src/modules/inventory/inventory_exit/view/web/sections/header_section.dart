part of '../inventory_exit_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryExitMediator.watch(context);
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
                        "Cliente",
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 6),
                      CustomAutocompleteTextfield<ClientInDb>(
                        initValue: viewController.selectedClient,
                        onClose: (value) => viewController.selectedClient = value,
                        titleBuilder: (value) => value.name,
                        onSearch: (value) async {
                          final repo = context.read<ClientsRepository>();
                          try {
                            final res = await repo.searchClientByKeyword(value);
                            return res;
                          } catch (e) {
                            return [];
                          }
                        },
                        suggestionBuilder: (value, close) {
                          return ListView.builder(
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              final client = value[index];
                              return ListTile(
                                title: Text(client.name),
                                onTap: () {
                                  viewController.selectedClient = client;
                                  close(client);
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
  const MenuActions({super.key});

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryExitMediator.watch(context);

    final isDisabled = !viewController.hasAllRequiredFields;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedCtrlButton(
          hotKey: "G",
          onPressed: isDisabled ? null : () => saveExit(context),
          icon: Icons.save,
          label: "Guardar",
        ),
      ],
    );
  }
}

Future<void> saveExit(BuildContext context) async {
  final viewController = InventoryExitMediator.read(context);

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

  final createExitDoc = viewController.generateCreateExitDoc();
  if (createExitDoc == null) return;

  if (!context.mounted) return;
  context.read<WriteExitDocCubit>().createNewExitDoc(createExitDoc);
}
