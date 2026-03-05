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
                      child: Row(
                        children: [
                          Flexible(child: SizedBox.expand()),
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => showGlobalStockSearchModal(context),
              label: const Text("Existencias Global"),
              icon: const Icon(Icons.search),
            ),

            ElevatedButton.icon(
              onPressed: () => saveAnonInvoiceAction(context),
              icon: Icon(saveIcon),
              label: Text(saveButtonTitle),
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
  final tableController = AnonInvoiceWebMediator.of(context).tableController;
  CreateInvoice newInvoice = createAnonInvoiceFromControllers(
    viewController,
    tableController,
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
  AnonInvoiceTableController tableController,
  BuildContext context,
) {
  final salesItems = tableController.items.map(
    (e) {
      final product = e.commercial.product;
      return SaleItem(
        product: ProductItem.fromJson(product.toJson()),
        selectedPrice: e.commercial.selectedPriceLevel,
        cost: product.account.averageCost,
        price: e.commercial.newPrice,
        quantity: e.commercial.quantity,
        discountPercentage: e.commercial.discountPercent,
        totalDiscount: e.commercial.totalDiscount,
        subTotal: e.commercial.subTotal,
        total: e.commercial.total,
      );
    },
  );

  final totalCost = salesItems.fold<int>(
    0,
    (previousValue, element) => previousValue + (element.cost * element.quantity),
  );

  final total = salesItems.fold<int>(
    0,
    (previousValue, element) => previousValue + element.total,
  );

  final (currentUser, currentBranch) = SessionTool.getFullUserFrom(context);

  final createClientInvoice = CreateInvoice(
    branchId: currentBranch.id,
    clientId: kSaleClientId,
    clientInfo: ClientInfo(name: "Sin Cliente", group: ""),
    docNumber: "",
    description: viewController.description,
    saleItems: salesItems.toList(),
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
