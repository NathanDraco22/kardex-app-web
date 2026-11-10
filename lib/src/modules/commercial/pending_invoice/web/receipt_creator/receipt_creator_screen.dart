import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_pending_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/write_receipt_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/modals/confirm_receipt_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/partial_payment_modal.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/pending_invoices_statement_image_dialog.dart';

class CreateReceiptMediator extends InheritedWidget {
  const CreateReceiptMediator({
    super.key,
    required super.child,
    required this.client,
    required this.invoices,
    required this.devolutions,
    this.creditNotes = const [],
  });

  final ClientInDb client;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;

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
    this.creditNotes = const [],
  });

  final ClientInDb client;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;

  @override
  Widget build(BuildContext context) {
    final receiptRepo = context.read<ReceiptsRepository>();
    return CreateReceiptMediator(
      client: client,
      invoices: invoices,
      devolutions: devolutions,
      creditNotes: creditNotes,
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
    final client = CreateReceiptMediator.of(context).client;
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

          context.read<ReadPendingInvoiceCubit>().loadPaginatedInvoices(client.id, getIt<AuthCubit>().currentBranchId);

          await DialogManager.showInfoDialog(
            context,
            "Recibo creado con éxito",
          );
          if (!context.mounted) return;
          await showReceiptViewerDialog(context, state.receipt);
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Crear Recibo de Pago"),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: "Compartir liquidación en imagen",
              onPressed: () {
                final mediator = CreateReceiptMediator.of(context);
                showPendingInvoicesStatementImageDialog(
                  context: context,
                  client: mediator.client,
                  invoices: mediator.invoices,
                  devolutions: mediator.devolutions,
                  creditNotes: mediator.creditNotes,
                  title: "Liquidación de Facturas",
                  badgeText: "LIQUIDACIÓN DE COBRO",
                  filePrefix: "liquidacion_cobro",
                  tableTitle: "FACTURAS A LIQUIDAR",
                );
              },
            ),
            const SizedBox(width: 8),
          ],
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
    final creditNotes = mediator.creditNotes;

    final total = invoices.fold(0, (int previousValue, invoice) {
      return previousValue + invoice.totalRemaining;
    });

    final devolutionTotal = devolutions.fold(0, (int previousValue, devolution) {
      return previousValue + devolution.total;
    });

    final creditNoteTotal = creditNotes.fold(0, (int previousValue, cn) {
      return previousValue + cn.total;
    });

    final totalWithDiscounts = total - devolutionTotal - creditNoteTotal;
    final totalPayable = totalWithDiscounts > 0 ? totalWithDiscounts : 0;
    final totalPayableFormatted = NumberFormatter.convertToMoneyLike(totalPayable);

    return BottomAppBar(
      height: 60,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PrimaryMenuButton(
                onPressed: () async {
                  if (creditNoteTotal > 0 && creditNoteTotal > (total - devolutionTotal)) {
                    await DialogManager.showErrorDialog(
                      context,
                      "No es posible abonar: Las notas de crédito (${NumberFormatter.convertToMoneyLike(creditNoteTotal)}) superan la deuda neta de las facturas (${NumberFormatter.convertToMoneyLike(total - devolutionTotal)}).\n\nSeleccione más facturas pendientes para aplicar el saldo.",
                    );
                    return;
                  }

                  final result = await showPartialPaymentModal(
                    context,
                    client: client,
                    invoices: invoices,
                    devolutions: devolutions,
                    creditNotes: creditNotes,
                  );

                  if (result == null) return;
                  if (!context.mounted) return;

                  final authState = getIt<AuthCubit>().state;
                  if (authState is! Authenticated) throw Exception("User or branch not found");
                  final currentUser = authState.session.user;
                  final currentBranch = authState.branch;

                  // 1. Calculate Applied Invoices (Cash Input + Linked Devolutions + Linked Credit Notes)
                  final appliedInvoices = <AppliedInvoice>[];
                  int receiptTotalCents = 0;

                  for (var invoice in invoices) {
                    final cashInput = result.payments[invoice.id] ?? 0.0;
                    final cashInputCents = (cashInput * 100).round();

                    // Find linked devolutions for this invoice
                    final linkedDevolutions = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
                    final linkedDevolutionTotal = linkedDevolutions.fold(0, (sum, d) => sum + d.total);

                    // Find linked credit notes for this invoice
                    final linkedCreditNotes = creditNotes.where(
                      (cn) =>
                          cn.invoiceId == invoice.id ||
                          (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber),
                    ).toList();
                    final linkedCreditNoteTotal = linkedCreditNotes.fold(0, (sum, cn) => sum + cn.total);

                    final totalAppliedCents = cashInputCents + linkedDevolutionTotal + linkedCreditNoteTotal;

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

                  // 3. Calculate Applied Credit Notes
                  final appliedCreditNotes = result.usedCreditNotes.map((cn) {
                    return AppliedCreditNote(
                      creditNoteId: cn.id,
                      docNumber: cn.docNumber,
                      amountApplied: cn.total,
                    );
                  }).toList();

                  // 4. Create Receipt
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
                    appliedCreditNotes: appliedCreditNotes,
                    paymentMethod: PaymentMethod.cash,
                    total: receiptTotalCents, // Only the cash amount is the receipt total
                    createdBy: UserInfo(
                      id: currentUser.id,
                      name: currentUser.username,
                    ),
                  );

                  if (!context.mounted) return;
                  context.read<WriteReceiptCubit>().createNewReceipt(createReceipt);
                },
                label: const Text("Abonar"),
              ),

              const SizedBox(width: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (creditNoteTotal > 0 && creditNoteTotal > (total - devolutionTotal))
                      ? Colors.grey
                      : Colors.green,
                ),
                onPressed: () async {
                  if (creditNoteTotal > 0 && creditNoteTotal > (total - devolutionTotal)) {
                    await DialogManager.showErrorDialog(
                      context,
                      "No es posible liquidar: El total de notas de crédito (${NumberFormatter.convertToMoneyLike(creditNoteTotal)}) supera el saldo pendiente de las facturas seleccionadas (${NumberFormatter.convertToMoneyLike(total - devolutionTotal)}).\n\nSeleccione más facturas pendientes para no perder el saldo excedente de las notas.",
                    );
                    return;
                  }

                  final res = await showConfirmReceiptModal(
                    context,
                    client,
                    invoices,
                    totalPayableFormatted,
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

                  final appliedCreditNotes = creditNotes.map((cn) {
                    return AppliedCreditNote(
                      creditNoteId: cn.id,
                      docNumber: cn.docNumber,
                      amountApplied: cn.total,
                    );
                  }).toList();

                  if (!context.mounted) return;

                  final authState = getIt<AuthCubit>().state;
                  if (authState is! Authenticated) throw Exception("User or branch not found");
                  final currentUser = authState.session.user;
                  final currentBranch = authState.branch;

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
                    appliedCreditNotes: appliedCreditNotes,
                    paymentMethod: PaymentMethod.cash,
                    total: totalPayable,
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
    final creditNotes = mediator.creditNotes;

    final total = invoices.fold(0, (int previousValue, invoice) {
      return previousValue + invoice.totalRemaining;
    });
    final devolutionTotal = devolutions.fold(0, (int previousValue, devolution) {
      return previousValue + devolution.total;
    });
    final creditNoteTotal = creditNotes.fold(0, (int previousValue, cn) {
      return previousValue + cn.total;
    });

    final totalFormatted = NumberFormatter.convertToMoneyLike(total);
    final devolutionTotalFormatted = NumberFormatter.convertToMoneyLike(devolutionTotal);
    final creditNoteTotalFormatted = NumberFormatter.convertToMoneyLike(creditNoteTotal);
    final totalWithDiscounts = total - devolutionTotal - creditNoteTotal;
    final totalPayable = totalWithDiscounts > 0 ? totalWithDiscounts : 0;
    final totalPayableFormatted = NumberFormatter.convertToMoneyLike(totalPayable);

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

                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Facturas: ${invoices.length}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Devoluciones: ${devolutions.length}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (creditNotes.isNotEmpty)
                            Text(
                              "Notas de Crédito: ${creditNotes.length}",
                              style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),

                      Text(
                        "Total a Pagar: $totalPayableFormatted",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (creditNoteTotal > 0 && creditNoteTotal > (total - devolutionTotal)) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Las notas de crédito superan el saldo de las facturas. Seleccione más facturas pendientes para poder procesar la liquidación sin perder saldo.",
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                              if (devolutions.isNotEmpty) ...[
                                const Divider(),
                                const Text("Devoluciones", style: TextStyle(fontWeight: FontWeight.bold)),
                                ..._buildDevolutionsRows(devolutions),
                              ],
                              if (creditNotes.isNotEmpty) ...[
                                const Divider(),
                                const Text("Notas de Crédito", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                ..._buildCreditNotesRows(creditNotes),
                              ],
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
                            if (devolutions.isNotEmpty)
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
                                      "- $devolutionTotalFormatted",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            if (creditNotes.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Notas de Crédito: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      "- $creditNoteTotalFormatted",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.deepPurple,
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
                                    totalPayableFormatted,
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

Iterable<Widget> _buildCreditNotesRows(List<CreditNoteInDb> creditNotes) sync* {
  for (var i = 0; i < creditNotes.length; i++) {
    final cn = creditNotes[i];
    final color = i.isOdd ? Colors.white : Colors.grey.shade200;

    yield Material(
      color: Colors.transparent,
      child: ListTile(
        tileColor: color,
        title: Row(
          children: [
            Text("NC #${cn.docNumber} (${cn.type.display})"),
            const Spacer(),
            Text(
              "- ${NumberFormatter.convertToMoneyLike(cn.total)}",
              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(
          DateTimeTool.formatddMMyy(cn.createdAt),
        ),
      ),
    );
  }
}
