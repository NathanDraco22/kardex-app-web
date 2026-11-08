import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/fast_payment_modal.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_invoice_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/widgets/design_system/app_status_badge.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';

Future<FastPaymentResult?> showInvoiceAcreditViewerScreen(
  BuildContext context,
  InvoiceInDb invoice, {
  List<DevolutionInDb> devolutions = const [],
  List<CreditNoteInDb> creditNotes = const [],
}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  if (!context.mounted) return null;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return null;
  return await Navigator.push<FastPaymentResult>(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _InvoiceAcreditViewer(
          invoice: invoice,
          branch: currentBranch,
          paperSize: paperSize,
          devolutions: devolutions,
          creditNotes: creditNotes,
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
    this.devolutions = const [],
    this.creditNotes = const [],
  });

  final InvoiceInDb invoice;
  final BranchInDb branch;
  final PaperSize paperSize;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;

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
    final targetDevolution = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
    final int devolutionsTotal = targetDevolution.fold(0, (sum, d) => sum + d.total);

    final targetCreditNotes = creditNotes.where((cn) =>
      cn.invoiceId == invoice.id ||
      (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber)
    ).toList();
    final int creditNotesTotal = targetCreditNotes.fold(0, (sum, cn) => sum + cn.total);

    final int netDebtBeforeCreditNotes = invoice.totalRemaining - devolutionsTotal;
    final bool isCreditNotesExceeding = creditNotesTotal > 0 && creditNotesTotal > netDebtBeforeCreditNotes;

    final int remaining = (invoice.totalRemaining - devolutionsTotal - creditNotesTotal) > 0
        ? (invoice.totalRemaining - devolutionsTotal - creditNotesTotal)
        : 0;
    final bool isPaidOut = remaining <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Factura:", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                NumberFormatter.convertToMoneyLike(invoice.total),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Abonado:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                NumberFormatter.convertToMoneyLike(invoice.amountPaid),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
              ),
            ],
          ),
          if (devolutionsTotal > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Devoluciones:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(
                  "- ${NumberFormatter.convertToMoneyLike(devolutionsTotal)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ],
            ),
          ],
          if (creditNotesTotal > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "Notas de Crédito:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppThemeTokens.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppStatusBadge.purple(
                      label: targetCreditNotes.length == 1
                          ? "1 nota"
                          : "${targetCreditNotes.length} notas",
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "- ${NumberFormatter.convertToMoneyLike(creditNotesTotal)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppThemeTokens.purple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: AppThemeTokens.purple,
                      ),
                      tooltip: "Ver Nota de Crédito",
                      onPressed: () {
                        if (targetCreditNotes.length == 1) {
                          showCreditNoteViewerDialog(context, targetCreditNotes.first);
                        } else {
                          _showCreditNotesSelector(context, targetCreditNotes);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
          const Divider(height: 16, thickness: 1),
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
          if (isCreditNotesExceeding) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Las notas de crédito vinculadas superan el saldo de esta factura. Seleccione múltiples facturas en el listado para amortizar el saldo completo sin excedentes.",
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: (isPaidOut || isCreditNotesExceeding)
                  ? null
                  : () async {
                      final paymentResult = await showFastPaymentModal(
                        context,
                        maxAmountToPay: NumberFormatter.convertFromCentsToDouble(remaining),
                        clientName: invoice.clientInfo.name,
                      );

                      if (paymentResult != null && context.mounted) {
                        Navigator.pop(context, paymentResult);
                      }
                    },
              icon: const Icon(Icons.payment),
              label: Text(
                isCreditNotesExceeding
                    ? "Notas de Crédito Exceden Saldo"
                    : (isPaidOut ? "Factura Pagada" : "Abonar a esta Factura"),
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCreditNotesExceeding
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreditNotesSelector(BuildContext context, List<CreditNoteInDb> notes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    "Notas de Crédito Vinculadas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cn = notes[index];
                      return ListTile(
                        leading: const Icon(Icons.assignment_turned_in, color: AppThemeTokens.purple),
                        title: Text("Nota #${cn.docNumber.isNotEmpty ? cn.docNumber : cn.id.substring(0, 8)}"),
                        subtitle: Text(
                          cn.type == CreditNoteType.devolution
                              ? "Por devolución de factura"
                              : (cn.description.isNotEmpty ? cn.description : "Por monto"),
                        ),
                        trailing: Text(
                          NumberFormatter.convertToMoneyLike(cn.total),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onTap: () {
                          Navigator.pop(modalContext);
                          showCreditNoteViewerDialog(context, cn);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
