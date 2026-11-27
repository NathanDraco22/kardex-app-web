import 'package:material_ui/material_ui.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/modals/confirm_receipt_modal.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';

class PartialPaymentResult {
  final Map<String, double> payments;
  final List<DevolutionInDb> usedDevolutions;
  final List<CreditNoteInDb> usedCreditNotes;
  final PaymentResult? payment;

  PartialPaymentResult({
    required this.payments,
    required this.usedDevolutions,
    this.usedCreditNotes = const [],
    this.payment,
  });
}

Future<PartialPaymentResult?> showPartialPaymentModal(
  BuildContext context, {
  required ClientInDb client,
  required List<InvoiceInDb> invoices,
  required List<DevolutionInDb> devolutions,
  List<CreditNoteInDb> creditNotes = const [],
}) {
  return showDialog<PartialPaymentResult>(
    context: context,
    builder: (context) => PartialPaymentModal(
      client: client,
      invoices: invoices,
      devolutions: devolutions,
      creditNotes: creditNotes,
    ),
  );
}

class PartialPaymentModal extends StatefulWidget {
  const PartialPaymentModal({
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
  State<PartialPaymentModal> createState() => _PartialPaymentModalState();
}

class _PartialPaymentModalState extends State<PartialPaymentModal> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, double> _inputAmounts = {};

  @override
  void initState() {
    super.initState();
    for (var invoice in widget.invoices) {
      _controllers[invoice.id] = TextEditingController();
      _inputAmounts[invoice.id] = 0.0;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<DevolutionInDb> _getLinkedDevolutions(String invoiceId) {
    final seen = <String>{};
    return widget.devolutions
        .where(
          (devolution) => devolution.originalInvoiceId == invoiceId && seen.add(devolution.id),
        )
        .toList();
  }

  int _getLinkedDevolutionsTotal(String invoiceId) {
    final linked = _getLinkedDevolutions(invoiceId);
    return linked.fold(0, (sum, item) => sum + item.total);
  }

  List<CreditNoteInDb> _getLinkedCreditNotes(InvoiceInDb invoice) {
    final seen = <String>{};
    return widget.creditNotes.where((cn) {
      if (!seen.add(cn.id)) return false;
      if (cn.invoiceId.isNotEmpty) {
        return cn.invoiceId == invoice.id;
      }
      return cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber;
    }).toList();
  }

  int _getLinkedCreditNotesTotal(InvoiceInDb invoice) {
    final linked = _getLinkedCreditNotes(invoice);
    return linked.fold(0, (sum, item) => sum + item.total);
  }

  int _getUnlinkedAmountNotesTotal(Set<String> linkedCreditNoteIds) {
    final seen = <String>{};
    return widget.creditNotes
        .where((cn) {
          if (cn.type != CreditNoteType.monto) return false;
          if (linkedCreditNoteIds.contains(cn.id)) return false;
          return seen.add(cn.id);
        })
        .fold(0, (sum, cn) => sum + cn.total);
  }

  int _getAvailableCapacityCents() {
    return widget.invoices.fold<int>(0, (sum, invoice) {
      final balanceCents = invoice.total - invoice.amountPaid;
      final inputCents = ((_inputAmounts[invoice.id] ?? 0.0) * 100).round();
      final devCents = _getLinkedDevolutionsTotal(invoice.id);
      final cnCents = _getLinkedCreditNotesTotal(invoice);
      final remaining = balanceCents - (inputCents + devCents + cnCents);
      return sum + (remaining > 0 ? remaining : 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Abonar a Facturas - ${widget.client.name}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
                      itemCount: widget.invoices.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final invoice = widget.invoices[index];
                        return _buildInvoiceRow(invoice);
                      },
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(InvoiceInDb invoice) {
    final linkedDevolutions = _getLinkedDevolutions(invoice.id);
    final devolutionTotal = _getLinkedDevolutionsTotal(invoice.id);

    final linkedCreditNotes = _getLinkedCreditNotes(invoice);
    final creditNoteTotal = _getLinkedCreditNotesTotal(invoice);

    // Calculate balance: (Total - Paid) in cents
    final balanceCents = invoice.total - invoice.amountPaid;

    // User input in plain double
    final inputAmount = _inputAmounts[invoice.id] ?? 0.0;
    // Input in cents for validation
    final inputCents = (inputAmount * 100).round();

    final totalApplyCents = inputCents + devolutionTotal + creditNoteTotal;

    final isValid = totalApplyCents <= balanceCents;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Factura #${invoice.docNumber}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Total: ${NumberFormatter.convertToMoneyLike(invoice.total)}"),
                    Text(
                      "Saldo: ${NumberFormatter.convertToMoneyLike(balanceCents)}",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            if (linkedDevolutions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Devoluciones Vinculadas:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    ...linkedDevolutions.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text("#${d.docNumber}"),
                            const Spacer(),
                            Text("- ${NumberFormatter.convertToMoneyLike(d.total)}"),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text("Total Devoluciones:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          "- ${NumberFormatter.convertToMoneyLike(devolutionTotal)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (linkedCreditNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notas de Crédito Vinculadas:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepPurple),
                    ),
                    ...linkedCreditNotes.map(
                      (cn) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text("#${cn.docNumber} (${cn.type.display})"),
                            const Spacer(),
                            Text(
                              "- ${NumberFormatter.convertToMoneyLike(cn.total)}",
                              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text("Total Notas de Crédito:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          "- ${NumberFormatter.convertToMoneyLike(creditNoteTotal)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[invoice.id],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [DecimalTextInputFormatter()],
                    decoration: InputDecoration(
                      labelText: "Monto a Abonar",
                      border: const OutlineInputBorder(),
                      prefixText: "\$ ",
                      errorText: isValid ? null : "El monto excede el saldo pendiente",
                    ),
                    onChanged: (value) {
                      setState(() {
                        final parsed = double.tryParse(value);
                        _inputAmounts[invoice.id] = parsed ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Se aplicará:", style: TextStyle(color: Colors.grey)),
                    Text(
                      NumberFormatter.convertToMoneyLike(totalApplyCents),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalCents = _inputAmounts.values.fold<int>(
      0,
      (sum, value) => sum + (value * 100).round(),
    );

    final linkedCreditNoteIds = <String>{};
    for (var invoice in widget.invoices) {
      linkedCreditNoteIds.addAll(
        _getLinkedCreditNotes(invoice).map((cn) => cn.id),
      );
    }
    final unlinkedAmountNotesTotal = _getUnlinkedAmountNotesTotal(
      linkedCreditNoteIds,
    );
    final availableCapacityCents = _getAvailableCapacityCents();
    final notesFit = unlinkedAmountNotesTotal <= availableCapacityCents;

    // Validate all inputs
    bool allValid = true;
    for (var invoice in widget.invoices) {
      final balanceCents = invoice.total - invoice.amountPaid;
      final inputCents = ((_inputAmounts[invoice.id] ?? 0.0) * 100).round();
      final devCents = _getLinkedDevolutionsTotal(invoice.id);
      final cnCents = _getLinkedCreditNotesTotal(invoice);
      if (inputCents + devCents + cnCents > balanceCents) {
        allValid = false;
        break;
      }
    }
    if (!notesFit) allValid = false;

    bool hasAnyApplication = false;
    for (var invoice in widget.invoices) {
      final input = _inputAmounts[invoice.id] ?? 0.0;
      final dev = _getLinkedDevolutionsTotal(invoice.id);
      final cn = _getLinkedCreditNotesTotal(invoice);
      if (input > 0 || dev > 0 || cn > 0) {
        hasAnyApplication = true;
        break;
      }
    }
    if (unlinkedAmountNotesTotal > 0) hasAnyApplication = true;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          PrimaryMenuButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            onPressed: (allValid && hasAnyApplication)
                ? () async {
                    final usedDevolutions = <DevolutionInDb>[];
                    final usedCreditNotes = <CreditNoteInDb>[];
                    final usedDevolutionIds = <String>{};
                    final usedCreditNoteIds = <String>{};

                    for (var invoice in widget.invoices) {
                      for (var devolution in _getLinkedDevolutions(invoice.id)) {
                        if (usedDevolutionIds.add(devolution.id)) {
                          usedDevolutions.add(devolution);
                        }
                      }
                      for (var creditNote in _getLinkedCreditNotes(invoice)) {
                        if (usedCreditNoteIds.add(creditNote.id)) {
                          usedCreditNotes.add(creditNote);
                        }
                      }
                    }

                    for (var creditNote in widget.creditNotes) {
                      if (creditNote.type == CreditNoteType.monto && usedCreditNoteIds.add(creditNote.id)) {
                        usedCreditNotes.add(creditNote);
                      }
                    }

                    PaymentResult? payment;
                    if (totalCents > 0) {
                      payment = await showPaymentConfirmationDialog(
                        context,
                        totalCents,
                        warningText:
                            "Se aplicará el abono a las facturas seleccionadas. Esta acción no se puede revertir.",
                      );
                      if (payment == null) return;
                    } else {
                      final confirm = await showConfirmPartialPayReceipt(
                        context,
                        widget.client,
                        widget.invoices.length,
                        NumberFormatter.convertToMoneyLike(totalCents),
                      );
                      if (confirm != true) return;
                    }

                    if (!mounted) return;
                    Navigator.pop(
                      context,
                      PartialPaymentResult(
                        payments: _inputAmounts,
                        usedDevolutions: usedDevolutions,
                        usedCreditNotes: usedCreditNotes,
                        payment: payment,
                      ),
                    );
                  }
                : null,
            label: const Text("Confirmar Abonos"),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unlinkedAmountNotesTotal > 0) ...[
                Text(
                  "Notas por monto: -${NumberFormatter.convertToMoneyLike(unlinkedAmountNotesTotal)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                if (!notesFit)
                  const Text(
                    "Las notas por monto superan el saldo disponible.",
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
              ],
              const Text("Total a Cobrar:"),
              Text(
                NumberFormatter.convertToMoneyLike(totalCents),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
