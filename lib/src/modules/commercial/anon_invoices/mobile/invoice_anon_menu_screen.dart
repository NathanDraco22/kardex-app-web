import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/cubits/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<void> showInvoiceAnonMenuScreen(
  BuildContext context,
  List<SaleItem> saleItems,
) async {
  final writeCubit = context.read<WriteAnonInvoiceCubit>();

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
  String description = '';
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
    return BlocListener<WriteAnonInvoiceCubit, WriteAnonInvoiceState>(
      listener: (context, state) async {
        if (state is WriteAnonInvoiceInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteAnonInvoiceError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteAnonInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          String message = "Factura guardada con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          await showInvoiceViewerDialog(context, state.invoice);

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
                  "Factura De Productos sin Cliente",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                            child: AbsorbPointer(
                              child: Opacity(
                                opacity: 0.3,
                                child: DropdownButtonFormField(
                                  onChanged: (value) {},
                                  key: const ValueKey('select_payment_type'),
                                  initialValue: PaymentType.cash,
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
                                  ],
                                ),
                              ),
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
        return ElevatedButton.icon(
          onPressed: () async {
            final totalCost = widget.saleItems.fold<int>(
              0,
              (previousValue, element) => previousValue + (element.cost * element.quantity),
            );

            final total = widget.saleItems.fold<int>(
              0,
              (previousValue, element) => previousValue + element.total,
            );

            final (currentUser, currentBranch) = SessionTool.getFullUserFrom(context);

            CreateInvoice newInvoice = CreateInvoice(
              branchId: currentBranch.id,
              clientId: kSaleClientId,
              clientInfo: ClientInfo(name: "Sin Cliente", group: ""),
              description: viewController.description,
              docNumber: "",
              saleItems: widget.saleItems,
              status: InvoiceStatus.paid,
              paymentType: PaymentType.cash,
              bankReference: "",
              totalCost: totalCost,
              amountPaid: total,
              total: total,
              createdBy: UserInfo(
                id: currentUser.id,
                name: currentUser.username,
              ),
            );

            final paymentResult = await showPaymentConfirmationDialog(
              context,
              total,
            );

            if (paymentResult == null) return;
            newInvoice = newInvoice.copyWithPaymentMethod(
              paymentResult.method,
              paymentResult.reference,
            );
            if (!context.mounted) return;
            context.read<WriteAnonInvoiceCubit>().createNewAnonInvoice(
              newInvoice,
            );
          },
          icon: const Icon(Icons.send),
          label: const Text("Facturar"),
        );
      },
    );
  }
}
