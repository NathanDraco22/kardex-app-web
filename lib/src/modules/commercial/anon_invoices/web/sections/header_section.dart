part of '../anon_invoices_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final mediator = AnonInvoiceWebMediator.of(context);
    final viewController = mediator.viewController;
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AbsorbPointer(
                          absorbing: true,
                          child: Column(
                            children: [
                              const Text("Fecha"),
                              const SizedBox(height: 6),
                              DateFieldSelector(
                                initDate: DateTime.now(),
                                onSelectedDate: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                      child: MenuActions(),
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
                                  onChanged: (value) {
                                    viewController.description = value;
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
    final viewController = AnonInvoiceWebMediator.of(context).viewController;

    String saveButtonTitle = "Facturar";

    IconData saveIcon = Icons.save;

    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        Function()? callback;

        if (viewController.items.isNotEmpty) {
          callback = () => saveAnonInvoiceAction(context);
        }

        return Row(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedCtrlButton(
              hotKey: "4",
              onPressed: () => context.pushNamed("invoice-history"),
              label: "Facturas",
              icon: Icons.blinds_closed,
            ),
            ElevatedCtrlButton(
              hotKey: "5",
              onPressed: () => showGlobalStockSearchModal(context),
              label: "Existencias Global",
              icon: Icons.search,
            ),
            const Spacer(),
            ElevatedCtrlButton(
              hotKey: "G",
              onPressed: callback,
              icon: saveIcon,
              label: saveButtonTitle,
            ),
          ],
        );
      },
    );
  }
}

Future<void> saveAnonInvoiceAction(
  BuildContext context,
) async {
  final viewController = AnonInvoiceWebMediator.of(context).viewController;
  if (viewController.items.isEmpty) {
    return;
  }

  for (var item in viewController.items) {
    if (item.quantity == 0) {
      await DialogManager.showInfoDialog(context, "${item.product.name} sin cantidad");
      return;
    }
  }

  CreateInvoice newInvoice = createAnonInvoiceFromControllers(
    viewController,
    context,
  );

  final paymentMethodSelected = await showPaymentConfirmationDialog(
    context,
    newInvoice.total,
  );

  if (paymentMethodSelected == null) return;

  newInvoice = newInvoice.copyWithPaymentMethod(
    paymentMethodSelected.method,
    paymentMethodSelected.reference,
  );

  if (!context.mounted) return;
  context.read<WriteAnonInvoiceCubit>().createNewAnonInvoice(
    newInvoice,
  );
}

CreateInvoice createAnonInvoiceFromControllers(
  AnonInvoiceViewController viewController,
  BuildContext context,
) {
  final salesItems = viewController.createSaleItemFromCommercial();

  final totalCost = salesItems.fold<int>(
    0,
    (previousValue, element) => previousValue + (element.cost * element.quantity),
  );

  final total = salesItems.fold<int>(
    0,
    (previousValue, element) => previousValue + element.total,
  );

  final authState = getIt<AuthCubit>().state;
  if (authState is! Authenticated) throw Exception("User or branch not found");
  final currentUser = authState.session.user;
  final currentBranch = authState.branch;

  final createClientInvoice = CreateInvoice(
    branchId: currentBranch.id,
    clientId: kSaleClientId,
    clientInfo: ClientInfo(name: "Sin Cliente", group: ""),
    docNumber: "",
    description: viewController.description,
    saleItems: salesItems,
    status: InvoiceStatus.paid,
    paymentType: PaymentType.cash,
    bankReference: "",
    amountPaid: total,
    totalCost: totalCost,
    total: total,
    createdBy: UserInfo(
      id: currentUser.id,
      name: currentUser.username,
    ),
  );

  return createClientInvoice;
}
