import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/confirmation_send_modal.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

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
                const Text(
                  "Cliente",
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                CustomAutocompleteTextfield<ClientInDb>(
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          const Text("Tipo de Pago"),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 46,
                            child: ListenableBuilder(
                              listenable: viewController,
                              builder: (context, _) {
                                final selectedClient = viewController.selectedClient;
                                final hasCredit = selectedClient?.isCreditActive ?? false;
                                final initValue = hasCredit ? PaymentType.credit : PaymentType.cash;
                                viewController.selectedPaymentType = initValue;
                                final dropdown = DropdownButtonFormField(
                                  key: ValueKey(selectedClient ?? 'select_payment_type'),
                                  initialValue: initValue,
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
                                    if (hasCredit)
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

                ElevatedButton.icon(
                  onPressed: () async {
                    final totalCost = widget.saleItems.fold<int>(
                      0,
                      (previousValue, element) => previousValue + (element.cost * element.quantity),
                    );

                    final total = widget.saleItems.fold<int>(
                      0,
                      (previousValue, element) => previousValue + element.total,
                    );

                    final newInvoice = CreateInvoice(
                      branchId: BranchesTool.getCurrentBranchId(),
                      clientId: viewController.selectedClient!.id,
                      description: viewController.description,
                      docNumber: "",
                      saleItems: widget.saleItems,
                      status: InvoiceStatus.open,
                      paymentType: viewController.selectedPaymentType!,
                      totalCost: totalCost,
                      total: total,
                    );

                    final res = await showConfirmationSendBottomModal(
                      context,
                      title: "Enviar Orden",
                      subtitle: "¿Desea enviar la orden de compra?",
                      content: Column(
                        children: [
                          Text(
                            viewController.selectedClient!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          Expanded(
                            child: ListView(
                              children: [
                                for (final item in newInvoice.saleItems)
                                  ListTile(
                                    title: Text(item.product.name),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          item.quantity.toString(),
                                        ),
                                        Text(NumberFormatter.convertFromCentsToDouble(item.price).toString()),
                                        Text(NumberFormatter.convertFromCentsToDouble(item.discount).toString()),
                                        Text(NumberFormatter.convertFromCentsToDouble(item.total).toString()),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                    if (res != true) return;
                    if (!context.mounted) return;
                    context.read<WriteInvoiceCubit>().createNewInvoice(
                      newInvoice,
                      viewController.selectedClient!,
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text("Enviar Orden de Compra"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
