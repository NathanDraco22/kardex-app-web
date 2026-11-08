import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/invoice_receipts_history_image_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

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
  List<ReceiptInDb>? _receipts;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    try {
      final repository = context.read<ReceiptsRepository>();
      final response = await repository.getAllReceiptsByInvoiceId(widget.invoice.id);
      if (!mounted) return;
      setState(() {
        _receipts = response.data;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
      });
    }
  }

  int _amountAppliedToInvoice(ReceiptInDb receipt) {
    return receipt.appliedInvoices
        .where((applied) => applied.invoiceId == widget.invoice.id)
        .fold(0, (sum, applied) => sum + applied.amountApplied);
  }

  @override
  Widget build(BuildContext context) {
    final receipts = _receipts;
    final totalAppliedToThisInvoice = (receipts ?? []).fold<int>(
      0,
      (sum, receipt) => sum + _amountAppliedToInvoice(receipt),
    );
    final invoiceTotal = widget.invoice.total;
    final remainingBalance = invoiceTotal - totalAppliedToThisInvoice;

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
              Expanded(
                child: _buildContent(
                  receipts,
                  invoiceTotal,
                  totalAppliedToThisInvoice,
                  remainingBalance,
                ),
              ),
              const SizedBox(height: 16),
              _buildActions(receipts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<ReceiptInDb>? receipts,
    int invoiceTotal,
    int totalAppliedToThisInvoice,
    int remainingBalance,
  ) {
    if (_error != null) {
      return Center(
        child: Text("Error al cargar abonos: $_error"),
      );
    }

    if (receipts == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                _buildSummaryRow(
                  "Total Abonos",
                  totalAppliedToThisInvoice,
                  color: Colors.green,
                ),
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
                    final amountApplied = _amountAppliedToInvoice(receipt);

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
  }

  Widget _buildActions(List<ReceiptInDb>? receipts) {
    final canShare = receipts != null && receipts.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Text(
            "${receipts?.length ?? 0} recibo(s)",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ElevatedButton.icon(
          onPressed: canShare
              ? () {
                  showInvoiceReceiptsHistoryImageDialog(
                    context: context,
                    invoice: widget.invoice,
                    receipts: receipts,
                  );
                }
              : null,
          icon: const Icon(Icons.image_outlined, size: 18),
          label: const Text("Compartir Imagen"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeTokens.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusSm),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
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
