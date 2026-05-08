import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/fast_payment_modal.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_invoice_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';

Future<double?> showInvoiceAcreditViewerScreen(BuildContext context, InvoiceInDb invoice) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  if (!context.mounted) return null;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return null;
  return await Navigator.push<double>(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _InvoiceAcreditViewer(
          invoice: invoice,
          branch: currentBranch,
          paperSize: paperSize,
        );
      },
    ),
  );
}

class _InvoiceAcreditViewer extends StatelessWidget {
  const _InvoiceAcreditViewer({
    required this.invoice,
    required this.branch,
    required this.paperSize,
  });

  final InvoiceInDb invoice;
  final BranchInDb branch;
  final PaperSize paperSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Factura #${invoice.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Exportar PDF (A4)",
            onPressed: () async {
              final template = SingleInvoiceTemplate(invoice: invoice, branch: branch);
              await PdfExportTool.export(template, fileName: "factura_${invoice.docNumber}.pdf");
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: "Compartir Factura",
            onPressed: () async {
              await shareInvoice(invoice, branch, paperSize: paperSize);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Factura",
            onPressed: () async {
              await printInvoice(invoice, branch, paperSize: paperSize);
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Expanded(
                    child: InvoiceViewerContent(
                      invoice: invoice,
                      branch: branch,
                    ),
                  ),
                  const Divider(thickness: 2),
                  _buildPaymentSummaryRow(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryRow(BuildContext context) {
    final int remaining = invoice.total - invoice.amountPaid;
    final bool isPaidOut = remaining <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Abonado:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                NumberFormatter.convertToMoneyLike(invoice.amountPaid),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Saldo Restante:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                NumberFormatter.convertToMoneyLike(remaining),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPaidOut ? Colors.grey : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isPaidOut
                  ? null
                  : () async {
                      final amountToPay = await showFastPaymentModal(
                        context,
                        maxAmountToPay: NumberFormatter.convertFromCentsToDouble(remaining),
                        clientName: invoice.clientInfo.name,
                      );

                      if (amountToPay != null && context.mounted) {
                        Navigator.pop(context, amountToPay);
                      }
                    },
              icon: const Icon(Icons.payment),
              label: Text(
                isPaidOut ? "Factura Pagada" : "Abonar a esta Factura",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
