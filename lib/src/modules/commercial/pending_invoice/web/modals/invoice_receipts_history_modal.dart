import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';

Future<void> showInvoiceReceiptsHistoryModal(BuildContext context, InvoiceInDb invoice) async {
  await showDialog(
    context: context,
    builder: (context) => InvoiceReceiptsHistoryModal(invoice: invoice),
  );
}

class InvoiceReceiptsHistoryModal extends StatefulWidget {
  final InvoiceInDb invoice;

  const InvoiceReceiptsHistoryModal({super.key, required this.invoice});

  @override
  State<InvoiceReceiptsHistoryModal> createState() => _InvoiceReceiptsHistoryModalState();
}

class _InvoiceReceiptsHistoryModalState extends State<InvoiceReceiptsHistoryModal> {
  late Future<List<ReceiptInDb>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = _fetchReceipts();
  }

  Future<List<ReceiptInDb>> _fetchReceipts() async {
    final repository = context.read<ReceiptsRepository>();
    final response = await repository.getAllReceiptsByInvoiceId(widget.invoice.id);
    return response.data; // Assuming response.data is the List<ReceiptInDb> based on ListResponse
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Historial de Pagos - Factura #${widget.invoice.docNumber}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // This content depends on data loading, so we use FutureBuilder
              Expanded(
                child: FutureBuilder<List<ReceiptInDb>>(
                  future: _receiptsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error al cargar abonos: ${snapshot.error}"),
                      );
                    }

                    final receipts = snapshot.data ?? [];

                    // Calculate totals
                    // We need to sum up the amount applied specifically to THIS invoice from each receipt
                    int totalAppliedToThisInvoice = 0;

                    for (var receipt in receipts) {
                      // Find the specific application entry for this invoice
                      // There might be multiple? Usually one per receipt per invoice.
                      // Filter just in case.
                      final application = receipt.appliedInvoices.where((ai) => ai.invoiceId == widget.invoice.id);
                      for (var app in application) {
                        totalAppliedToThisInvoice += app.amountApplied;
                      }
                    }

                    final invoiceTotal = widget.invoice.total;
                    final remainingBalance = invoiceTotal - totalAppliedToThisInvoice;

                    return Column(
                      children: [
                        // Summary Card
                        Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildSummaryRow("Total Factura", invoiceTotal),
                                const Divider(),
                                _buildSummaryRow("Total Abonos", totalAppliedToThisInvoice, color: Colors.green),
                                const Divider(),
                                _buildSummaryRow(
                                  "Saldo Restante",
                                  remainingBalance,
                                  isBold: true,
                                  color: remainingBalance > 0 ? Colors.red : Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Detalle de Abonos",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: receipts.isEmpty
                              ? const Center(child: Text("No se encontraron abonos registrados."))
                              : ListView.separated(
                                  itemCount: receipts.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final receipt = receipts[index];
                                    final amountApplied = receipt.appliedInvoices
                                        .where((ai) => ai.invoiceId == widget.invoice.id)
                                        .fold(0, (sum, item) => sum + item.amountApplied);

                                    return ListTile(
                                      leading: const Icon(Icons.receipt_long, color: Colors.blue),
                                      title: Text("Recibo #${receipt.docNumber}"),
                                      subtitle: Text(DateTimeTool.formatddMMyy(receipt.createdAt)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            NumberFormatter.convertToMoneyLike(amountApplied),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                        ],
                                      ),
                                      onTap: () {
                                        showReceiptViewerDialog(context, receipt);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          NumberFormatter.convertToMoneyLike(amount),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
