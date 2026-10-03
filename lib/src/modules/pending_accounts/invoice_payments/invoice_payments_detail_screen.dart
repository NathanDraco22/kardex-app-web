import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/invoice_receipts_history_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/widgets/custom_receipt_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<void> showInvoicePaymentsDetailScreen(BuildContext context, InvoiceInDb invoice) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InvoicePaymentsDetailScreen(invoice: invoice),
    ),
  );
}

class InvoicePaymentsDetailScreen extends StatefulWidget {
  final InvoiceInDb invoice;

  const InvoicePaymentsDetailScreen({super.key, required this.invoice});

  @override
  State<InvoicePaymentsDetailScreen> createState() => _InvoicePaymentsDetailScreenState();
}

class _InvoicePaymentsDetailScreenState extends State<InvoicePaymentsDetailScreen> {
  List<ReceiptInDb>? _receipts;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    setState(() {
      _receipts = null;
      _error = null;
    });
    try {
      final repository = context.read<ReceiptsRepository>();
      final response = await repository.getAllReceiptsByInvoiceId(widget.invoice.id);
      final receipts = [...response.data]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _receipts = receipts;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
      });
    }
  }

  int get _totalApplied {
    var total = 0;
    for (final receipt in _receipts ?? []) {
      total += _amountAppliedToThisInvoice(receipt);
    }
    return total;
  }

  int _amountAppliedToThisInvoice(ReceiptInDb receipt) {
    return receipt.appliedInvoices
        .where((applied) => applied.invoiceId == widget.invoice.id)
        .fold(0, (sum, applied) => sum + applied.amountApplied);
  }

  Future<void> _exportHistoryPdf() async {
    final receipts = _receipts;
    if (receipts == null) return;

    final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
    final template = InvoiceReceiptsHistoryTemplate(
      invoice: widget.invoice,
      receipts: receipts,
      branch: currentBranch,
    );
    await PdfExportTool.export(template, fileName: "abonos_factura_${widget.invoice.docNumber}.pdf");
  }

  @override
  Widget build(BuildContext context) {
    final totalApplied = _totalApplied;
    final totalRemaining = widget.invoice.total - totalApplied;

    return Scaffold(
      appBar: AppBar(
        title: Text("Abonos - Factura #${widget.invoice.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Exportar Historial de Abonos (PDF)",
            onPressed: _receipts == null ? null : _exportHistoryPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInvoiceSummary(totalApplied, totalRemaining),
                  const Text(
                    "Historial de Abonos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Expanded(
                    child: _buildReceiptsContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary(int totalApplied, int totalRemaining) {
    final invoice = widget.invoice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Factura #${invoice.docNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "${DateTimeTool.formatddMMyy(invoice.createdAt)} ${DateTimeTool.formatHHmm(invoice.createdAt)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              invoice.clientInfo.name,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
            ),
            const Divider(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Factura"),
                Text(
                  NumberFormatter.convertToMoneyLike(invoice.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Abonos"),
                Text(
                  NumberFormatter.convertToMoneyLike(totalApplied),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Saldo Restante"),
                Text(
                  NumberFormatter.convertToMoneyLike(totalRemaining),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: totalRemaining > 0 ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PrimaryMenuButton(
              onPressed: () {
                showInvoiceViewerDialog(context, invoice);
              },
              icon: const Icon(Icons.description),
              label: const Text("Ver Factura"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptsContent() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                "Error al cargar los abonos \n $_error",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SecondaryMenuButton(
                onPressed: _fetchReceipts,
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    final receipts = _receipts;
    if (receipts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (receipts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "No se encontraron abonos registrados",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      child: ListView.separated(
        itemCount: receipts.length,
        separatorBuilder: (context, index) => const Divider(height: 0.0),
        itemBuilder: (context, index) {
          final receipt = receipts[index];
          final tileColor = index.isOdd ? Colors.grey.shade200 : Colors.white;
          final amountApplied = _amountAppliedToThisInvoice(receipt);

          return CustomReceiptListTile(
            receipt: receipt,
            backgroundColor: tileColor,
            trailing: Text(
              NumberFormatter.convertToMoneyLike(amountApplied),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              showReceiptViewerDialog(context, receipt);
            },
          );
        },
      ),
    );
  }
}
