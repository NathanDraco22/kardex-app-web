part of '../client_invoices_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = ClientInvoiceWebMediator.of(context).viewController;
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Cliente",
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 6),
                      CustomAutocompleteTextfield<ClientInDb>(
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
                        child: Column(
                          children: [
                            const Text("Tipo de Pago"),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 44,
                              child: ListenableBuilder(
                                key: ValueKey(viewController.selectedClient ?? 'client_selected'),
                                listenable: viewController,
                                builder: (context, _) {
                                  final selectedClient = viewController.selectedClient;

                                  final dropdown = DropdownButtonFormField(
                                    key: ValueKey(selectedClient ?? 'select_payment_type'),
                                    initialValue: viewController.selectedPaymentType,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: PaymentType.cash,
                                        child: Text("Contado"),
                                      ),
                                      if (selectedClient?.isCreditActive ?? false)
                                        const DropdownMenuItem(
                                          value: PaymentType.credit,
                                          child: Text("Credito"),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        viewController.selectedPaymentType = value;
                                      }
                                    },
                                  );

                                  if (viewController.selectedClient == null) {
                                    return AbsorbPointer(
                                      child: Opacity(
                                        opacity: 0.3,
                                        child: dropdown,
                                      ),
                                    );
                                  }
                                  return dropdown;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AbsorbPointer(
                          absorbing: true,
                          child: Column(
                            children: [
                              const Text("Fecha"),
                              const SizedBox(height: 6),
                              DateFieldSelector(
                                initDate: viewController.selectedDate,
                                onSelectedDate: (value) {},
                              ),
                            ],
                          ),
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
                                  onChanged: (value) {
                                    viewController.description = value;
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
    final viewController = ClientInvoiceWebMediator.of(context).viewController;
    final tableController = ClientInvoiceWebMediator.of(context).tableController;

    final cubit = context.read<WriteInvoiceCubit>();

    String saveButtonTitle = "Facturar";
    if (cubit.isOrder) saveButtonTitle = "Enviar Orden";

    IconData saveIcon = Icons.save;
    if (cubit.isOrder) saveIcon = Icons.send;

    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        final canSave = viewController.selectedClient != null && tableController.items.isNotEmpty;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: canSave
                  ? () async {
                      final newInvoice = createInvoiceFromControllers(
                        viewController,
                        tableController,
                      );

                      final res = await showConfirmationInvoiceDialog(
                        context,
                        viewController.selectedClient!,
                        newInvoice,
                        isOrder: cubit.isOrder,
                      );

                      if (res != true) return;

                      if (!context.mounted) return;
                      context.read<WriteInvoiceCubit>().createNewInvoice(
                        newInvoice,
                        viewController.selectedClient!,
                      );
                    }
                  : null,
              icon: Icon(saveIcon),
              label: Text(saveButtonTitle),
            ),
          ],
        );
      },
    );
  }
}

CreateInvoice createInvoiceFromControllers(
  ViewController viewController,
  ClientInvoiceTableController tableController,
) {
  final salesItems = tableController.items.map(
    (e) {
      final product = e.commercial.product;
      return SaleItem(
        product: ProductItem.fromJson(product.toJson()),
        cost: product.account.averageCost,
        price: product.saleProfile.salePrice,
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

  final selectedClient = viewController.selectedClient!;

  final createClientInvoice = CreateInvoice(
    branchId: BranchesTool.getCurrentBranchId(),
    clientId: selectedClient.id,
    clientInfo: ClientInfo(
      name: selectedClient.name,
      address: selectedClient.address,
      cardId: selectedClient.cardId,
      location: selectedClient.location,
      phone: selectedClient.phone,
      email: selectedClient.email,
    ),
    docNumber: "",
    description: viewController.description,
    saleItems: salesItems.toList(),
    status: InvoiceStatus.open,
    paymentType: viewController.selectedPaymentType,
    totalCost: totalCost,
    total: total,
  );

  return createClientInvoice;
}
