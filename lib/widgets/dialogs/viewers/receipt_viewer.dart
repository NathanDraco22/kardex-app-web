import 'package:material_ui/material_ui.dart';
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
import 'package:kardex_app_front/widgets/dialogs/viewers/adaptive_viewer.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';

Future<void> showReceiptViewerDialog(BuildContext context, ReceiptInDb receipt) async {
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;
  await showAdaptiveViewer(
    context: context,
    builder: (context) => _ReceiptViewer(
      receipt,
      paperSize: paperSize,
      onExportPdf: () async {
        final template = SingleReceiptTemplate(receipt: receipt, branch: currentBranch);
        await PdfExportTool.export(template, fileName: "recibo_${receipt.docNumber}.pdf");
      },
    ),
  );
}

Future<void> showReceiptViewerDialogFromDocNumber(BuildContext context, String docNumber) async {
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await showAdaptiveViewer(
    context: context,
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
          if (!receipt.isCancelled &&
              receipt.appliedDevolutions.isEmpty &&
              receipt.appliedCreditNotes.isEmpty)
            Gate(
              filters: const [ReceiptCancellationsGateFilter()],
              child: IconButton(
                tooltip: "Solicitar anulación",
                onPressed: () => _showRequestCancellationDialog(context),
                icon: const Icon(Icons.cancel_schedule_send_outlined),
              ),
            ),
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
                  if (receipt.isCancelled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "RECIBO ANULADO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (receipt.cancelledBy != null || receipt.cancelledAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (receipt.cancelledBy != null) "Por: ${receipt.cancelledBy!.name}",
                                if (receipt.cancelledAt != null)
                                  "${DateTimeTool.formatddMMyy(receipt.cancelledAt!)} ${DateTimeTool.formatHHmm(receipt.cancelledAt!)}",
                              ].join(" • "),
                              style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                            ),
                          ],
                          if (receipt.cancellationReason != null &&
                              receipt.cancellationReason!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              "Motivo: ${receipt.cancellationReason!}",
                              style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                  if (currentBranch.formattedRuc != null)
                    Text(
                      currentBranch.formattedRuc!,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
        if (receipt.paymentDetail != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Recibido:",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 8),
              Text(
                receipt.paymentDetail!.formatTenderedLabel(NumberFormatter.currency),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          if (receipt.paymentDetail!.changeAmount > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Cambio:",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 8),
                Text(
                  receipt.paymentDetail!.formatChangeLabel(NumberFormatter.currency),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _showRequestCancellationDialog(BuildContext context) async {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return;

    final repo = context.read<ReceiptCancellationRequestsRepository>();
    final sent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RequestReceiptCancellationDialog(
        receipt: receipt,
        requestedBy: UserInfo(
          id: authState.session.user.id,
          name: authState.session.user.username,
        ),
        repository: repo,
      ),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Solicitud de anulación de recibo enviada."),
        ),
      );
    }
  }
}

class _RequestReceiptCancellationDialog extends StatefulWidget {
  final ReceiptInDb receipt;
  final UserInfo requestedBy;
  final ReceiptCancellationRequestsRepository repository;

  const _RequestReceiptCancellationDialog({
    required this.receipt,
    required this.requestedBy,
    required this.repository,
  });

  @override
  State<_RequestReceiptCancellationDialog> createState() =>
      _RequestReceiptCancellationDialogState();
}

class _RequestReceiptCancellationDialogState
    extends State<_RequestReceiptCancellationDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repository.createRequest(
        CreateReceiptCancellationRequest(
          receiptId: widget.receipt.id,
          reason: _reasonController.text.trim(),
          requestedBy: widget.requestedBy,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: Text("Solicitar anulación #${widget.receipt.docNumber}"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Esta solicitud deberá ser aprobada por un supervisor o administrador antes de anular el recibo y revertir los abonos.",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                autofocus: true,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: "Motivo de anulación *",
                  hintText: "Ej. Error en monto o método de pago",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return "Ingresa un motivo de al menos 3 caracteres.";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Enviar solicitud"),
          ),
        ],
      ),
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
