part of '../pending_invoice_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = PendingInvoiceMediator.of(context);
    final viewController = mediator.notifier!;
    return Card(
      key: ValueKey(viewController.selectedClient ?? "null"),
      child: BlocBuilder<ReadPendingInvoiceCubit, ReadInvoiceState>(
        builder: (context, state) {
          if (state is ReadInvoiceInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.grey),
                  Text(
                    "Elige un cliente",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is ReadInvoiceLoading) {
            Future(() => viewController.clearSelected());
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadInvoiceError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ReadInvoiceSuccess;

          final invoices = state.invoices;
          final devolutions = state.devolutions;
          final creditNotes = state.creditNotes;

          viewController.devolutions = devolutions;
          viewController.creditNotes = creditNotes;

          if (invoices.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (creditNotes.isNotEmpty)
                  CreditNotesSummaryTile(creditNotes: creditNotes),
                const Expanded(
                  child: Center(
                    child: Text(
                      "No hay facturas pendientes",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (creditNotes.isNotEmpty)
                CreditNotesSummaryTile(creditNotes: creditNotes),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  padding: const EdgeInsets.only(bottom: 40, right: 4, left: 4),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
              final tileColor = RowColorTool.getRowColor(index);

              final currentInvoice = invoices[index];

              return InvoiceDevolutionTile(
                tileColor: tileColor,
                invoice: currentInvoice,
                devolutions: devolutions,
                creditNotes: creditNotes,
                isSelected: viewController.isInSelected(currentInvoice),
                onChanged: (value) {
                  if (value == true) {
                    viewController.addToSelected(currentInvoice);
                    return;
                  }

                  viewController.removeFromSelected(currentInvoice);
                },

                onViewInvoice: () async {
                  final paymentResult = await showInvoiceAcreditViewerScreen(
                    context,
                    currentInvoice,
                    devolutions: devolutions,
                    creditNotes: creditNotes,
                  );
                  if (paymentResult != null && context.mounted) {
                    final amountCents = (paymentResult.amount * 100).round();
                    final client = viewController.selectedClient!;
                    final authState = getIt<AuthCubit>().state;
                    if (authState is! Authenticated) throw Exception("User or branch not found");
                    final currentUser = authState.session.user;
                    final currentBranch = authState.branch;

                    final targetDevolutions = devolutions.where((d) => d.originalInvoiceId == currentInvoice.id).toList();
                    final targetCreditNotes = creditNotes.where((cn) => cn.invoiceId == currentInvoice.id || (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == currentInvoice.docNumber)).toList();

                    final (createReceipt, errorOrSummary) = FastReceiptLogic.allocateFastPayment(
                      paymentAmountCents: amountCents,
                      invoices: [currentInvoice],
                      devolutions: targetDevolutions,
                      creditNotes: targetCreditNotes,
                      client: client,
                      branchId: currentBranch.id,
                      currentUserId: currentUser.id,
                      currentUserName: currentUser.username,
                      paymentMethod: paymentResult.method,
                      bankReference: paymentResult.bankReference,
                    );

                    if (createReceipt != null) {
                      context.read<WriteReceiptCubit>().createNewReceipt(createReceipt);
                    } else {
                      DialogManager.showErrorDialog(context, errorOrSummary);
                    }
                  }
                },
                onViewDevolutions: () {
                  final targetDevolution = devolutions
                      .where(
                        (d) => d.originalInvoiceId == currentInvoice.id,
                      )
                      .toList();
                  showDialog(
                    context: context,
                    builder: (context) {
                      final total = targetDevolution.fold<int>(
                        0,
                        (previousValue, element) => previousValue + element.total,
                      );
                      return _DevolutionDialog(total: total, devolutions: targetDevolution);
                    },
                  );
                },
                onViewCreditNotes: () {
                  final targetCreditNotes = creditNotes
                      .where(
                        (cn) =>
                            cn.invoiceId == currentInvoice.id ||
                            (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == currentInvoice.docNumber),
                      )
                      .toList();
                  if (targetCreditNotes.length == 1) {
                    showCreditNoteViewerDialog(context, targetCreditNotes.first);
                  } else if (targetCreditNotes.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => _CreditNotesDialog(creditNotes: targetCreditNotes),
                    );
                  }
                },
                onViewReceipts: () {
                  showInvoiceReceiptsHistoryModal(context, currentInvoice);
                },
              );
            },
          ),
        ),
      ],
    );
        },
      ),
    );
  }
}

class _DevolutionDialog extends StatelessWidget {
  const _DevolutionDialog({
    required this.total,
    required this.devolutions,
  });

  final int total;
  final List<DevolutionInDb> devolutions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Devoluciones"),
      actions: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Total",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
      content: SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: devolutions.length,
          itemBuilder: (context, index) {
            final currentDevolutions = devolutions[index];
            final circleColor = currentDevolutions.status == DevolutionStatus.confirmed ? Colors.green : Colors.blue;
            return ListTile(
              leading: Icon(Icons.circle, color: circleColor),
              tileColor: RowColorTool.getRowColor(index),
              title: Text("#${currentDevolutions.docNumber}"),
              onTap: () {
                showDevolutionViewerDialog(context, currentDevolutions);
              },
              subtitle: Text(
                DateTimeTool.formatddMMyyEs(currentDevolutions.createdAt),
              ),
              trailing: Text(
                NumberFormatter.convertToMoneyLike(currentDevolutions.total),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CreditNotesDialog extends StatelessWidget {
  const _CreditNotesDialog({required this.creditNotes});

  final List<CreditNoteInDb> creditNotes;

  @override
  Widget build(BuildContext context) {
    final total = creditNotes.fold<int>(0, (sum, cn) => sum + cn.total);
    return AlertDialog(
      title: const Text("Notas de Crédito"),
      actions: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Total",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
      content: SizedBox(
        width: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: creditNotes.length,
          itemBuilder: (context, index) {
            final cn = creditNotes[index];
            final circleColor = cn.status == CreditNoteStatus.confirmed ? Colors.deepPurple : Colors.grey;
            return ListTile(
              leading: Icon(Icons.circle, color: circleColor),
              tileColor: RowColorTool.getRowColor(index),
              title: Text("#${cn.docNumber} (${cn.type.display})"),
              onTap: () {
                showCreditNoteViewerDialog(context, cn);
              },
              subtitle: Text(
                DateTimeTool.formatddMMyyEs(cn.createdAt),
              ),
              trailing: Text(
                NumberFormatter.convertToMoneyLike(cn.total),
              ),
            );
          },
        ),
      ),
    );
  }
}
