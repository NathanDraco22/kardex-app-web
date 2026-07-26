part of '../client_invoices_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = ClientInvoiceWebMediator.of(context).viewController;
    return Row(
      children: [
        SizedBox(
          width: 425,
          child: ClientSelectorCard(
            initialClient: viewController.selectedClient,
            onChange: (value) {
              viewController.selectedClient = value;
            },
          ),
        ),
        SizedBox(
          width: 125,
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
                      AbsorbPointer(
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
                      const SizedBox(height: 6),

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

    final cubit = context.read<WriteInvoiceCubit>();

    final currentUser = getIt<AuthCubit>().user;

    if (currentUser == null) {
      throw Exception("User not found in Client Invoices");
    }

    final webScreenWidget = context.findAncestorWidgetOfExactType<ClientInvoicesScreenWeb>();

    String saveButtonTitle = webScreenWidget?.actionButtonLabel ?? "Facturar";
    if (webScreenWidget?.actionButtonLabel == null) {
      if (cubit.documentType == CommercialDocumentType.order) saveButtonTitle = "Enviar Orden";
      if (cubit.documentType == CommercialDocumentType.quote) saveButtonTitle = "Guardar Cotización";
    }

    IconData saveIcon = Icons.save;
    if (cubit.isOrder) saveIcon = Icons.send;

    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        final canSave = viewController.selectedClient != null && viewController.items.isNotEmpty;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedCtrlButton(
              onPressed: () => context.pushNamed("client-list"),
              hotKey: "4",
              icon: Icons.people,
              label: "Clientes",
            ),

            ElevatedCtrlButton(
              icon: saveIcon,
              hotKey: "G",
              label: saveButtonTitle,
              onPressed: canSave
                  ? () async {
                      if (viewController.hasZeroPriceItems) {
                        DialogManager.showErrorDialog(
                          context,
                          "No se puede facturar porque hay productos con precio en 0. Por favor, edita o elimina estos productos.",
                        );
                        return;
                      }
                      final newInvoice = viewController.generateCreateInvoice(context);
                      if (newInvoice == null) return;

                      if (!cubit.isOrder && viewController.selectedPaymentType == PaymentType.cash) {
                        final paymentResult = await showPaymentConfirmationDialog(
                          context,
                          newInvoice.total,
                        );
                        if (paymentResult == null) return;
                        final updatedInvoice = newInvoice.copyWithPaymentMethod(
                          paymentResult.method,
                          paymentResult.reference,
                        );

                        if (!context.mounted) return;
                        context.read<WriteInvoiceCubit>().createNewInvoice(
                          updatedInvoice,
                          viewController.selectedClient!,
                        );
                      } else {
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
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }
}
