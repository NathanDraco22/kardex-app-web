import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/write_receipt_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/modals/confirm_receipt_modal.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

class CreateReceiptMediator extends InheritedWidget {
  const CreateReceiptMediator({
    super.key,
    required super.child,
    required this.client,
    required this.invoices,
  });

  final ClientInDb client;
  final List<InvoiceInDb> invoices;

  static CreateReceiptMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CreateReceiptMediator>()!;
  }

  @override
  bool updateShouldNotify(CreateReceiptMediator oldWidget) {
    return false;
  }
}

class ReceiptCreatorScreen extends StatelessWidget {
  const ReceiptCreatorScreen({
    super.key,
    required this.client,
    required this.invoices,
  });

  final ClientInDb client;
  final List<InvoiceInDb> invoices;

  @override
  Widget build(BuildContext context) {
    final receiptRepo = context.read<ReceiptsRepository>();
    return CreateReceiptMediator(
      client: client,
      invoices: invoices,
      child: BlocProvider(
        create: (context) => WriteReceiptCubit(
          receiptsRepository: receiptRepo,
        ),
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateReceiptMediator.of(context);
    final client = mediator.client;
    final invoices = mediator.invoices;
    final total = invoices.fold(0, (int previousValue, invoice) => previousValue + invoice.total);
    final totalFormatted = NumberFormatter.convertToMoneyLike(total);

    return BlocListener<WriteReceiptCubit, WriteReceiptState>(
      listener: (context, state) async {
        if (state is WriteReceiptInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteReceiptError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteReceiptSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);

          await DialogManager.showInfoDialog(
            context,
            "Recibo creado con éxito",
          );
          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Crear Recibo de Pago"),
        ),
        body: const _Body(),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final res = await showConfirmReceiptModal(
                    context,
                    client,
                    invoices,
                    totalFormatted,
                  );
                  if (res != true) return;

                  final appliedInvoices = invoices.map((invoice) {
                    return AppliedInvoice(
                      invoiceId: invoice.id,
                      amountApplied: invoice.total,
                    );
                  }).toList();

                  final createReceipt = CreateReceipt(
                    branchId: BranchesTool.getCurrentBranchId(),
                    clientId: client.id,
                    appliedInvoices: appliedInvoices,
                    paymentMethod: PaymentMethod.cash,
                    total: total,
                  );
                  if (!context.mounted) return;
                  context.read<WriteReceiptCubit>().createNewReceipt(createReceipt);
                },
                child: const Text("Liquidar Facturas"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateReceiptMediator.of(context);
    final client = mediator.client;
    final invoices = mediator.invoices;
    final total = invoices.fold(0, (int previousValue, invoice) => previousValue + invoice.total);
    final totalFormatted = NumberFormatter.convertToMoneyLike(total);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Facturas a Cancelar: ${invoices.length}",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      Text(
                        "Total a Pagar: $totalFormatted",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          "Detalle:",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              const Divider(),
                              ..._buildInvoiceRows(invoices),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Iterable<Widget> _buildInvoiceRows(List<InvoiceInDb> invoices) sync* {
  for (var i = 0; i < invoices.length; i++) {
    final currentInvoice = invoices[i];
    final color = i.isOdd ? Colors.white : Colors.grey.shade200;

    yield Material(
      color: Colors.transparent,
      child: ListTile(
        tileColor: color,
        title: Row(
          children: [
            Text("Fact #${currentInvoice.docNumber}"),
            const Spacer(),
            Text(NumberFormatter.convertToMoneyLike(currentInvoice.total)),
          ],
        ),
        subtitle: Text(
          DateTimeTool.formatddMMyyyy(
            currentInvoice.createdAt,
          ),
        ),
      ),
    );
  }
}
