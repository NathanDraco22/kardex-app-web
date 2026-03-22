part of '../create_transfer_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.watch(context)!;
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
                  Row(
                    children: [
                      const Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          "Sucursal Origen:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(BranchesTool.getCurrentBranchName()),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text("Sucursal Destino"),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final branches = BranchesTool.branches
                          .where((element) => element.id != BranchesTool.getCurrentBranchId())
                          .toList();

                      final res = await showBranchSelectionDialog(context, branches);
                      if (res == null) return;
                      headerData.destinationBranch = res;
                      mediator.refresh();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(headerData.destinationBranch?.name ?? "Seleccionar destino"),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
  const MenuActions({super.key});

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.watch(context)!;

    final isDisabled = !mediator.hasAllRequiredFields();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isDisabled
              ? null
              : () async {
                  await saveTransfer(context);
                },
          icon: const Icon(Icons.save),
          label: const Text("Guardar"),
        ),
      ],
    );
  }
}

Future<void> saveTransfer(BuildContext context) async {
  final mediator = CreateTransferMediator.read(context)!;
  if (!mediator.hasAllRequiredFields()) {
    return;
  }

  if (mediator.hasProductWithZeroValue()) {
    await DialogManager.showErrorDialog(context, "No se pueden guardar productos con cantidad 0");
    return;
  }

  final res = await DialogManager.slideToConfirmActionDialog(
    context,
    "¿Deseas Guardar la Transferencia? (No se puede deshacer)",
  );

  if (res != true) return;

  if (!context.mounted) return;

  final mediatorRead = CreateTransferMediator.read(context)!;
  final headerData = mediatorRead.headerData;
  final productTableController = mediatorRead.productTableController;

  final items = productTableController.rows.map((e) {
    return TransferItem(
      id: e.product.id,
      name: e.product.name,
      code: e.product.code,
      unitName: e.product.unitName,
      brandName: e.product.brandName,
      quantity: e.quantity,
      cost: e.unitaryCost,
      expirationDate: e.expirationDate?.millisecondsSinceEpoch,
      salePrice: e.product.saleProfile.salePrice,
      salePrice2: e.product.saleProfile.salePrice2,
      salePrice3: e.product.saleProfile.salePrice3,
    );
  }).toList();

  final (currentUser, _) = SessionTool.getFullUserFrom(context);

  final originBranch = BranchesTool.getCurrentBranch();

  final createTransfer = CreateTransfer(
    origin: originBranch!.id,
    originName: originBranch.name,
    destination: headerData.destinationBranch!.id,
    destinationName: headerData.destinationBranch!.name,
    status: TransferStatus.inTransit,
    description: headerData.observations ?? "",
    items: items,
    createdBy: UserInfo(
      id: currentUser.id,
      name: currentUser.username,
    ),
    docNumber: "",
  );

  context.read<WriteTransferCubit>().createTransfer(createTransfer);
}
