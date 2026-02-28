import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/write_receipt_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/modals/confirm_receipt_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/partial_payment_modal.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';

class CreateReceiptMediator extends InheritedWidget {
  const CreateReceiptMediator({
    super.key,
    required super.child,
    required this.client,
    required this.invoices,
    required this.devolutions,
  });

  final ClientInDb client;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;

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
    required this.devolutions,
  });

  final ClientInDb client;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;

  @override
  Widget build(BuildContext context) {
    final receiptRepo = context.read<ReceiptsRepository>();
    return CreateReceiptMediator(
      client: client,
      invoices: invoices,
      devolutions: devolutions,
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
          await showReceiptViewerDialog(context, state.receipt);
          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Crear Recibo de Pago"),
        ),
        body: const _Body(),
        bottomNavigationBar: const _CreateReceiptBottomBar(),
      ),
    );
  }
}

class _CreateReceiptBottomBar extends StatelessWidget {
  const _CreateReceiptBottomBar();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateReceiptMediator.of(context);
    final client = mediator.client;
    final invoices = mediator.invoices;
    final devolutions = mediator.devolutions;
    final total = invoices.fold(0, (int previousValue, invoice) {
      return previousValue + invoice.totalRemaining;
    });

    final devolutionTotal = devolutions.fold(0, (int previousValue, devolution) {
      return previousValue + devolution.total;
    });
    final totalWithDevolutions = total - devolutionTotal;
    final totalWithDevolutionsFormatted = NumberFormatter.convertToMoneyLike(totalWithDevolutions);
    return BottomAppBar(
      height: 60,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final result = await showPartialPaymentModal(
                    context,
                    client: client,
                    invoices: invoices,
                    devolutions: devolutions,
                  );

                  if (result == null) return;
                  if (!context.mounted) return;

                  final (currentUser, currentBranch) = SessionTool.getFullUserFrom(context);

                  // 1. Calculate Applied Invoices (Cash Input + Linked Devolutions)
                  final appliedInvoices = <AppliedInvoice>[];
                  int receiptTotalCents = 0;

                  for (var invoice in invoices) {
                    final cashInput = result.payments[invoice.id] ?? 0.0;
                    final cashInputCents = (cashInput * 100).round();

                    // Find linked devolutions for this invoice
                    final linkedDevolutions = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();

                    final linkedDevolutionTotal = linkedDevolutions.fold(0, (sum, d) => sum + d.total);

                    final totalAppliedCents = cashInputCents + linkedDevolutionTotal;

                    if (totalAppliedCents > 0) {
                      appliedInvoices.add(
                        AppliedInvoice(
                          invoiceId: invoice.id,
                          docNumber: invoice.docNumber,
                          amountApplied: totalAppliedCents,
                        ),
                      );
                      receiptTotalCents += cashInputCents;
                    }
                  }

                  // 2. Calculate Applied Devolutions
                  final appliedDevolutions = result.usedDevolutions.map((devolution) {
                    return AppliedDevolution(
                      devolutionId: devolution.id,
                      docNumber: devolution.docNumber,
                      amountApplied: devolution.total,
                    );
                  }).toList();

                  // Confirm before proceeding

                  // 3. Create Receipt
                  final createReceipt = CreateReceipt(
                    branchId: currentBranch.id,
                    clientInfo: ClientInfo(
                      name: client.name,
                      group: client.group,
                      address: client.address,
                      phone: client.phone,
                      email: client.email,
                      cardId: client.cardId,
                      location: client.location,
                    ),
                    clientId: client.id,
                    appliedInvoices: appliedInvoices,
                    appliedDevolutions: appliedDevolutions,
                    paymentMethod: PaymentMethod.cash,
                    total: receiptTotalCents, // Only the cash amount is the receipt total
                    createdBy: UserInfo(
                      id: currentUser.id,
                      name: currentUser.username,
                    ),
                  );

                  if (!context.mounted) return;
                  // Use the same cubit to create the receipt
                  context.read<WriteReceiptCubit>().createNewReceipt(createReceipt);
                },
                child: const Text("Abonar"),
              ),

              const SizedBox(width: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final res = await showConfirmReceiptModal(
                    context,
                    client,
                    invoices,
                    totalWithDevolutionsFormatted,
                  );
                  if (res != true) return;

                  final appliedInvoices = invoices.map((invoice) {
                    return AppliedInvoice(
                      invoiceId: invoice.id,
                      docNumber: invoice.docNumber,
                      amountApplied: invoice.totalRemaining,
                    );
                  }).toList();

                  final appliedDevolutions = devolutions.map((devolution) {
                    return AppliedDevolution(
                      devolutionId: devolution.id,
                      docNumber: devolution.docNumber,
                      amountApplied: devolution.total,
                    );
                  }).toList();

                  if (!context.mounted) return;

                  final (currentUser, currentBranch) = SessionTool.getFullUserFrom(context);

                  final createReceipt = CreateReceipt(
                    branchId: currentBranch.id,
                    clientInfo: ClientInfo(
                      name: client.name,
                      group: client.group,
                      address: client.address,
                      phone: client.phone,
                      email: client.email,
                      cardId: client.cardId,
                      location: client.location,
                    ),
                    clientId: client.id,
                    appliedInvoices: appliedInvoices,
                    appliedDevolutions: appliedDevolutions,
                    paymentMethod: PaymentMethod.cash,
                    total: totalWithDevolutions,
                    createdBy: UserInfo(
                      id: currentUser.id,
                      name: currentUser.username,
                    ),
                  );

                  if (!context.mounted) return;
                  context.read<WriteReceiptCubit>().createNewReceipt(createReceipt);
                },
                child: const Text("Liquidar"),
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
    final devolutions = mediator.devolutions;
    final total = invoices.fold(0, (int previousValue, invoice) {
      return previousValue + invoice.totalRemaining;
    });
    final devolutionTotal = devolutions.fold(0, (int previousValue, devolution) {
      return previousValue + devolution.total;
    });
    final totalFormatted = NumberFormatter.convertToMoneyLike(total);
    final devolutionTotalFormatted = NumberFormatter.convertToMoneyLike(devolutionTotal);
    final totalWithDevolutions = total - devolutionTotal;
    final totalWithDevolutionsFormatted = NumberFormatter.convertToMoneyLike(totalWithDevolutions);
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        client.location ?? "--",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),

                      Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Facturas: ${invoices.length}",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),

                          Text(
                            "Devoluciones: ${devolutions.length}",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "Total a Pagar: $totalWithDevolutionsFormatted",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                              const Text("Facturas", style: TextStyle(fontWeight: FontWeight.bold)),
                              ..._buildInvoiceRows(invoices),
                              const Divider(),
                              const Text("Devoluciones", style: TextStyle(fontWeight: FontWeight.bold)),
                              ..._buildDevolutionsRows(devolutions),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Facturas: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    totalFormatted,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Devoluciones: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    devolutionTotalFormatted,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Total a Pagar: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    totalWithDevolutionsFormatted,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
            Text(NumberFormatter.convertToMoneyLike(currentInvoice.totalRemaining)),
          ],
        ),
        subtitle: Text(
          DateTimeTool.formatddMMyy(
            currentInvoice.createdAt,
          ),
        ),
      ),
    );
  }
}

Iterable<Widget> _buildDevolutionsRows(List<DevolutionInDb> devolutions) sync* {
  for (var i = 0; i < devolutions.length; i++) {
    final currentDevolutions = devolutions[i];
    final color = i.isOdd ? Colors.white : Colors.grey.shade200;

    yield Material(
      color: Colors.transparent,
      child: ListTile(
        tileColor: color,
        title: Row(
          children: [
            Text("Devol #${currentDevolutions.docNumber}"),
            const Spacer(),
            Text(
              NumberFormatter.convertToMoneyLike(
                currentDevolutions.total,
              ),
            ),
          ],
        ),
        subtitle: Text(
          DateTimeTool.formatddMMyy(
            currentDevolutions.createdAt,
          ),
        ),
      ),
    );
  }
}
