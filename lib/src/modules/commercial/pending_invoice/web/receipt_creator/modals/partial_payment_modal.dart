import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/modals/confirm_receipt_modal.dart';

class PartialPaymentResult {
  final Map<String, double> payments;
  final List<DevolutionInDb> usedDevolutions;
  final List<CreditNoteInDb> usedCreditNotes;

  PartialPaymentResult({
    required this.payments,
    required this.usedDevolutions,
    this.usedCreditNotes = const [],
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
    return widget.devolutions.where((d) => d.originalInvoiceId == invoiceId).toList();
  }

  int _getLinkedDevolutionsTotal(String invoiceId) {
    final linked = _getLinkedDevolutions(invoiceId);
    return linked.fold(0, (sum, item) => sum + item.total);
  }

  List<CreditNoteInDb> _getLinkedCreditNotes(InvoiceInDb invoice) {
    return widget.creditNotes.where(
      (cn) =>
          cn.invoiceId == invoice.id ||
          (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber),
    ).toList();
  }

  int _getLinkedCreditNotesTotal(InvoiceInDb invoice) {
    final linked = _getLinkedCreditNotes(invoice);
    return linked.fold(0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    double totalCashInput = 0;
    _inputAmounts.forEach((_, value) => totalCashInput += value);

    return Dialog.fullscreen(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Abonar a Facturas - ${widget.client.name}"),
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
                  _buildBottomBar(totalCashInput),
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
                Text(
                  "Factura #${invoice.docNumber}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
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
                    decoration: InputDecoration(
                      labelText: "Monto a Abonar (Efectivo)",
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

  Widget _buildBottomBar(double totalCashInput) {
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
      child: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onPressed: (allValid && hasAnyApplication)
                ? () async {
                    final usedDevolutions = <DevolutionInDb>[];
                    final usedCreditNotes = <CreditNoteInDb>[];
                    for (var invoice in widget.invoices) {
                      final linkedDevs = _getLinkedDevolutions(invoice.id);
                      if (linkedDevs.isNotEmpty) {
                        usedDevolutions.addAll(linkedDevs);
                      }
                      final linkedCns = _getLinkedCreditNotes(invoice);
                      if (linkedCns.isNotEmpty) {
                        usedCreditNotes.addAll(linkedCns);
                      }
                    }

                    // Add any amount credit notes
                    final amountNotes = widget.creditNotes.where(
                      (cn) => cn.type == CreditNoteType.monto && !usedCreditNotes.contains(cn),
                    );
                    usedCreditNotes.addAll(amountNotes);

                    final confirm = await showConfirmPartialPayReceipt(
                      context,
                      widget.client,
                      widget.invoices.length,
                      NumberFormatter.convertToMoneyLike((totalCashInput * 100).round()),
                    );

                    if (confirm != true) return;
                    if (!context.mounted) return;
                    final currentContext = context;
                    if (!currentContext.mounted) return;
                    Navigator.pop(
                      currentContext,
                      PartialPaymentResult(
                        payments: _inputAmounts,
                        usedDevolutions: usedDevolutions,
                        usedCreditNotes: usedCreditNotes,
                      ),
                    );
                  }
                : null,
            child: const Text("Confirmar Abonos"),
          ),

          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Total Recibo (Efectivo/Pago):"),
              Text(
                NumberFormatter.convertToMoneyLike((totalCashInput * 100).round()),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
