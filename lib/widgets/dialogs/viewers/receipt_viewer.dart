import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/printers/receipt_printer.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_receipt_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';

import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

Future<void> showReceiptViewerDialog(BuildContext context, ReceiptInDb receipt) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _ReceiptViewer(
        receipt,
        paperSize: paperSize,
        onExportPdf: () async {
          final template = SingleReceiptTemplate(receipt: receipt, branch: currentBranch);
          await PdfExportTool.export(template, fileName: "recibo_${receipt.docNumber}.pdf");
        },
      ),
    ),
  );
}

Future<void> showReceiptViewerDialogFromDocNumber(BuildContext context, String docNumber) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<ReceiptInDb>(
          future: context.read<ReceiptsRepository>().getReceiptByDocNumber(docNumber),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (asyncSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Text("Error al cargar el recibo \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final receipt = asyncSnapshot.data!;

            return _ReceiptViewer(
              receipt,
              paperSize: paperSize,
              onExportPdf: () async {
                final template = SingleReceiptTemplate(receipt: receipt, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "recibo_${receipt.docNumber}.pdf");
              },
            );
          },
        );
      },
    ),
  );
}

class _ReceiptViewer extends StatelessWidget {
  const _ReceiptViewer(
    this.receipt, {
    this.paperSize = PaperSize.mm80,
    this.onExportPdf,
  });

  final ReceiptInDb receipt;
  final PaperSize paperSize;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    // Asumimos que obtienes la sucursal del AuthCubit
    final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recibo #${receipt.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Exportar PDF (A4)",
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: "Compartir Recibo",
            onPressed: () {
              shareReceipt(receipt, currentBranch, paperSize: paperSize);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Recibo",
            onPressed: () {
              printReceipt(receipt, currentBranch, paperSize: paperSize);
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Ink(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Recibo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "No. ${receipt.docNumber}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Column(
                        children: [
                          Text(
                            DateTimeTool.formatddMMyy(receipt.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            DateTimeTool.formatHHmm(receipt.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentBranch.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final label = Text(
                        receipt.paymentMethod.display,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );

                      if (receipt.paymentMethod != PaymentMethod.cash &&
                          receipt.bankReference.isNotEmpty) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label,
                            Text(
                              " - Ref: ${receipt.bankReference}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }

                      return label;
                    },
                  ),
                  Text(
                    "Cliente: ${receipt.clientInfo.name}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Text(
                    "Elaborado por: ${receipt.createdBy.name}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(height: 24),

                  const Text("Facturas Aplicadas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        const Divider(height: 2, thickness: 2),
                        ..._buildInvoiceRows(context, receipt.appliedInvoices),
                        const SizedBox(height: 8),

                        if (receipt.appliedDevolutions.isNotEmpty) ...[
                          const Text(
                            "Devoluciones Aplicadas",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 2, thickness: 2),
                          ..._buildDevolutionsRows(context, receipt.appliedDevolutions),
                          const SizedBox(height: 8),
                        ],

                        if (receipt.appliedCreditNotes.isNotEmpty) ...[
                          const Text(
                            "Notas de Crédito Aplicadas",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppThemeTokens.purple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 2, thickness: 2),
                          ..._buildCreditNotesRows(context, receipt.appliedCreditNotes),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 24),

                  _buildReceiptTotalsSummary(receipt),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptTotalsSummary(ReceiptInDb receipt) {
    final totalInvoices = receipt.appliedInvoices.fold(
      0,
      (previousValue, element) => previousValue + element.amountApplied,
    );
    final totalDevolutions = receipt.appliedDevolutions.fold(
      0,
      (previousValue, element) => previousValue + element.amountApplied,
    );
    final totalCreditNotes = receipt.appliedCreditNotes.fold(
      0,
      (previousValue, element) => previousValue + element.amountApplied,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (totalDevolutions > 0 || totalCreditNotes > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Total Facturas:", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: Text(
                  NumberFormatter.convertToMoneyLike(totalInvoices),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          if (totalDevolutions > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Devoluciones:", style: TextStyle(fontSize: 14, color: Colors.red)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Text(
                    "- ${NumberFormatter.convertToMoneyLike(totalDevolutions)}",
                    style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
          if (totalCreditNotes > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Notas de Crédito:", style: TextStyle(fontSize: 14, color: AppThemeTokens.purple)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Text(
                    "- ${NumberFormatter.convertToMoneyLike(totalCreditNotes)}",
                    style: const TextStyle(fontSize: 14, color: AppThemeTokens.purple, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Total Recibo (Cobrado):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                Text(
                  NumberFormatter.convertToMoneyLike(receipt.total),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppThemeTokens.success),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Iterable<Widget> _buildInvoiceRows(BuildContext context, List<AppliedInvoice> invoices) sync* {
  for (var i = 0; i < invoices.length; i++) {
    final currentInvoice = invoices[i];
    final tileColor = RowColorTool.getRowColor(i);
    yield ListTile(
      tileColor: tileColor,
      minTileHeight: 40,
      onTap: () {
        showInvoiceViewerDialogFromDocNumber(context, currentInvoice.docNumber);
      },
      title: Text(
        "#${currentInvoice.docNumber}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        NumberFormatter.convertToMoneyLike(currentInvoice.amountApplied),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

Iterable<Widget> _buildDevolutionsRows(BuildContext context, List<AppliedDevolution> devolutions) sync* {
  for (var i = 0; i < devolutions.length; i++) {
    final currentDevolutions = devolutions[i];
    final tileColor = RowColorTool.getRowColor(i);
    yield ListTile(
      tileColor: tileColor,
      minTileHeight: 40,
      onTap: () {
        showDevolutionViewerDialogFromId(context, currentDevolutions.devolutionId);
      },
      title: Text(
        "#${currentDevolutions.docNumber}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        NumberFormatter.convertToMoneyLike(currentDevolutions.amountApplied),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

Iterable<Widget> _buildCreditNotesRows(BuildContext context, List<AppliedCreditNote> creditNotes) sync* {
  for (var i = 0; i < creditNotes.length; i++) {
    final currentCreditNote = creditNotes[i];
    final tileColor = RowColorTool.getRowColor(i);
    yield ListTile(
      tileColor: tileColor,
      minTileHeight: 40,
      onTap: () {
        showCreditNoteViewerDialogFromId(context, currentCreditNote.creditNoteId);
      },
      title: Text(
        "NC #${currentCreditNote.docNumber}",
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeTokens.purple),
      ),
      trailing: Text(
        NumberFormatter.convertToMoneyLike(currentCreditNote.amountApplied),
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeTokens.purple),
      ),
    );
  }
}
