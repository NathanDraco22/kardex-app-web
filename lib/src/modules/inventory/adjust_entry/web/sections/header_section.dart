part of '../../adjust_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final mediator = AdjustEntryMediator.read(context)!;
    final headerData = mediator.headerData;
    final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;

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
                      TitleTextField(
                        title: "Sucursal",
                        initialValue: currentBranch.name,
                        readOnly: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            const Text("Fecha Doc"),
                            const SizedBox(height: 6),
                            DateFieldSelector(
                              initDate: DateTime.now(),
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
                          Flexible(child: SizedBox.expand()),
                          Flexible(child: MenuActions()),
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
                                    headerData.description = p0;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Flexible(child: SizedBox.expand()),
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
    final mediator = AdjustEntryMediator.watch(context)!;
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
  final mediator = AdjustEntryMediator.read(context)!;
  if (!mediator.hasAllRequiredFields()) return;

  if (mediator.hasProductWithZeroValue()) {
    await DialogManager.showErrorDialog(context, "No se pueden guardar productos con valor 0");
    return;
  }

  final res = await DialogManager.slideToConfirmActionDialog(
    context,
    "¿Deseas guardar el Ajuste? (No se puede deshacer)",
  );

  if (res != true) return;

  final items = mediator.productTableController.rows.map((e) {
    return EntryItem(
      productId: e.product.id,
      productName: e.product.name,
      cost: e.unitaryCost,
      quantity: e.quantity,
      expirationDate: e.expirationDate?.millisecondsSinceEpoch,
      brandName: e.product.brandName,
      code: e.product.code,
      unitName: e.product.unitName,
    );
  }).toList();

  if (!context.mounted) return;

  final authState = context.read<AuthCubit>().state as Authenticated;

  final currentUser = authState.session.user;

  final createDto = CreateAdjustEntry(
    branchId: BranchesTool.getCurrentBranchId(),
    description: mediator.headerData.description ?? "",
    items: items,
    createdBy: UserInfo(id: currentUser.id, name: currentUser.username),
  );

  context.read<WriteAdjustEntryCubit>().createAdjustEntry(createDto);
}
