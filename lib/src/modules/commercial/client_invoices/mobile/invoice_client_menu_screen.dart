import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/client_selector_card.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

import '../cubit/write_invoice_cubit.dart';
import '../widgets/confirmation_send_modal.dart';

Future<void> showInvoiceClientMenuScreen(BuildContext context, List<SaleItem> saleItems) async {
  final writeCubit = context.read<WriteInvoiceCubit>();

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: writeCubit,
        child: InvoiceClientMenuScreen(
          saleItems: saleItems,
        ),
      ),
    ),
  );
}

class ViewController extends ChangeNotifier {
  ClientInDb? _selectedClient;
  PaymentType? _selectedPaymentType;

  ClientInDb? get selectedClient => _selectedClient;
  PaymentType? get selectedPaymentType => _selectedPaymentType;

  String description = '';

  set selectedClient(ClientInDb? value) {
    _selectedClient = value;
    if (value == null) {
      _selectedPaymentType = PaymentType.cash;
    }

    if (value?.isCreditActive == true) {
      _selectedPaymentType = PaymentType.credit;
    }

    notifyListeners();
  }

  set selectedPaymentType(PaymentType? value) {
    _selectedPaymentType = value;
    notifyListeners();
  }
}

class InvoiceClientMenuScreen extends StatelessWidget {
  const InvoiceClientMenuScreen({
    super.key,
    required this.saleItems,
  });

  final List<SaleItem> saleItems;

  @override
  Widget build(BuildContext context) {
    return _RootScaffold(saleItems);
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold(this.saleItems);

  final List<SaleItem> saleItems;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteInvoiceCubit, WriteInvoiceState>(
      listener: (context, state) async {
        if (state is WriteInvoiceInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteInvoiceError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          final cubit = context.read<WriteInvoiceCubit>();
          String message = "Factura guardada con éxito";
          if (cubit.isOrder) message = "Orden de compra enviada con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Cliente")),
        body: _Body(saleItems),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body(this.saleItems);

  final List<SaleItem> saleItems;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late ViewController viewController;

  @override
  void initState() {
    viewController = ViewController();
    super.initState();
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 170,
                  child: ClientSelectorCard(
                    onChange: (value) => viewController.selectedClient = value,
                  ),
                ),
                const SizedBox(height: 16),
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
                                    viewController.selectedPaymentType = value;
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

                    const SizedBox(
                      width: 8,
                    ),

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

                const SizedBox(height: 16),

                TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                  onChanged: (value) {
                    viewController.description = value;
                  },
                ),

                const SizedBox(height: 16),

                _SendButton(viewController: viewController, widget: widget),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.viewController,
    required this.widget,
  });

  final ViewController viewController;
  final _Body widget;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        final cubit = context.read<WriteInvoiceCubit>();
        String label = "Enviar Orden de Compra";
        String dialogTitle = "Enviar Orden";
        String dialogSubtitle = "¿Desea enviar la orden de compra?";

        if (cubit.documentType == CommercialDocumentType.invoice) {
          label = "Crear Factura";
          dialogTitle = "Crear Factura";
          dialogSubtitle = "¿Desea crear la factura?";
        } else if (cubit.documentType == CommercialDocumentType.quote) {
          label = "Guardar Cotización";
          dialogTitle = "Guardar Cotización";
          dialogSubtitle = "¿Desea guardar la cotización?";
        }

        return ElevatedButton.icon(
          onPressed: viewController.selectedClient == null
              ? null
              : () async {
                  final totalCost = widget.saleItems.fold<int>(
                    0,
                    (previousValue, element) => previousValue + (element.cost * element.quantity),
                  );

                  final total = widget.saleItems.fold<int>(
                    0,
                    (previousValue, element) => previousValue + element.total,
                  );

                  final selectedClient = viewController.selectedClient!;

                  final (currentUser, currentBranch) = SessionTool.getFullUserFrom(context);

                  final newInvoice = CreateInvoice(
                    branchId: currentBranch.id,
                    clientId: selectedClient.id,
                    clientInfo: ClientInfo(
                      name: selectedClient.name,
                      group: selectedClient.group,
                      address: selectedClient.address,
                      cardId: selectedClient.cardId,
                      location: selectedClient.location,
                      phone: selectedClient.phone,
                      email: selectedClient.email,
                    ),
                    description: viewController.description,
                    docNumber: "",
                    saleItems: widget.saleItems,
                    status: InvoiceStatus.open,
                    paymentType: viewController.selectedPaymentType!,
                    bankReference: "",
                    totalCost: totalCost,
                    total: total,
                    createdBy: UserInfo(
                      id: currentUser.id,
                      name: currentUser.username,
                    ),
                  );

                  final res = await showConfirmationSendBottomModal(
                    context,
                    title: dialogTitle,
                    subtitle: dialogSubtitle,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          viewController.selectedClient!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Expanded(
                          child: ListView(
                            children: [
                              for (final item in newInvoice.saleItems)
                                ListTile(
                                  title: Text(item.product.name),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.quantity.toString(),
                                      ),
                                      Text(NumberFormatter.convertToMoneyLike(item.price).toString()),
                                      Text(
                                        NumberFormatter.convertToMoneyLike(
                                          item.totalDiscount,
                                        ).toString(),
                                      ),
                                      Text(NumberFormatter.convertToMoneyLike(item.total).toString()),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Text(
                          "Total: ${NumberFormatter.convertToMoneyLike(newInvoice.total)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );

                  if (res != true) return;
                  if (!context.mounted) return;
                  context.read<WriteInvoiceCubit>().createNewInvoice(
                    newInvoice,
                    viewController.selectedClient!,
                    currentUser,
                  );
                },
          icon: const Icon(Icons.send),
          label: Text(label),
        );
      },
    );
  }
}
