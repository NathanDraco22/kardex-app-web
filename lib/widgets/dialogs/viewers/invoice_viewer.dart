import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_invoice_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';

Future<void> showInvoiceViewerDialog(BuildContext context, InvoiceInDb invoice) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _InvoiceViewer(
          invoice: invoice,
          branch: currentBranch,
          onShare: () => shareInvoice(invoice, currentBranch, paperSize: paperSize),
          onPrint: () => printInvoice(invoice, currentBranch, paperSize: paperSize),
          onExportPdf: () async {
            final template = SingleInvoiceTemplate(invoice: invoice, branch: currentBranch);
            await PdfExportTool.export(template, fileName: "factura_${invoice.docNumber}.pdf");
          },
        );
      },
    ),
  );
}

Future<void> showInvoiceViewerDialogFromDocNumber(BuildContext context, String docNumber) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder(
          future: context.read<InvoicesRepository>().getInvoiceByDocNumber(docNumber),
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
                  child: Text("Error al cargar la factura \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final invoice = asyncSnapshot.data!;

            return _InvoiceViewer(
              invoice: invoice,
              branch: currentBranch,
              onShare: () => shareInvoice(invoice, currentBranch, paperSize: paperSize),
              onPrint: () => printInvoice(invoice, currentBranch, paperSize: paperSize),
              onExportPdf: () async {
                final template = SingleInvoiceTemplate(invoice: invoice, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "factura_${invoice.docNumber}.pdf");
              },
            );
          },
        );
      },
    ),
  );
}

Future<void> showInvoiceViewerDialogFromId(BuildContext context, String id) async {
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder(
          future: context.read<InvoicesRepository>().getInvoiceById(id),
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
                  child: Text("Error al cargar la factura \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final invoice = asyncSnapshot.data!;

            return _InvoiceViewer(
              invoice: invoice,
              branch: currentBranch,
              onShare: () => shareInvoice(invoice, currentBranch, paperSize: paperSize),
              onPrint: () => printInvoice(invoice, currentBranch, paperSize: paperSize),
              onExportPdf: () async {
                final template = SingleInvoiceTemplate(invoice: invoice, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "factura_${invoice.docNumber}.pdf");
              },
            );
          },
        );
      },
    ),
  );
}

class _InvoiceViewer extends StatelessWidget {
  const _InvoiceViewer({
    required this.invoice,
    required this.branch,
    this.onShare,
    this.onPrint,
    this.onExportPdf,
  });

  final InvoiceInDb invoice;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Factura #${invoice.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Exportar PDF (A4)",
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: "Compartir Factura",
            onPressed: onShare,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Factura",
            onPressed: onPrint,
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
              child: FutureBuilder<List<CreditNoteInDb>>(
                future: context.read<CreditNotesRepository>().getCreditNotesByInvoiceId(invoice.id),
                builder: (context, snapshot) {
                  return InvoiceViewerContent(
                    invoice: invoice,
                    branch: branch,
                    creditNotes: snapshot.data ?? const [],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InvoiceViewerContent extends StatelessWidget {
  const InvoiceViewerContent({
    super.key,
    required this.invoice,
    required this.branch,
    this.creditNotes = const [],
  });

  final InvoiceInDb invoice;
  final BranchInDb branch;
  final List<CreditNoteInDb> creditNotes;

  @override
  Widget build(BuildContext context) {
    final totalDiscount = invoice.saleItems.fold(
      0,
      (previousValue, element) => previousValue + element.totalDiscount,
    );
    final invoiceSubTotal = invoice.saleItems.fold(
      0,
      (element, previousValue) => previousValue.subTotal + element,
    );
    final secondaryTotal = NumberFormatter.convertInvoiceTotalToSecondaryMoney(invoice.total);
    final secondaryCurrency = NumberFormatter.secondaryCurrency;

    final visibleCreditNotes = creditNotes.where((cn) =>
      cn.status != CreditNoteStatus.rejected && cn.status != CreditNoteStatus.cancelled
    ).toList();

    final approvedCreditNotes = visibleCreditNotes.where((cn) =>
      cn.status == CreditNoteStatus.approved || cn.status == CreditNoteStatus.confirmed
    ).toList();
    final int creditNotesTotal = approvedCreditNotes.fold(0, (sum, cn) => sum + cn.total);

    final pendingApprovalCreditNotes = visibleCreditNotes.where((cn) =>
      cn.status == CreditNoteStatus.emitted || cn.status == CreditNoteStatus.open
    ).toList();

    final netInvoiceTotal = (invoice.total - creditNotesTotal) > 0 ? (invoice.total - creditNotesTotal) : 0;
    return Column(
      children: [
        const Text(
          "Factura",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. ${invoice.docNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateTimeTool.formatddMMyy(invoice.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateTimeTool.formatHHmm(invoice.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              branch.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Builder(
              builder: (context) {
                final label = Text(
                  invoice.paymentType.typeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );

                if (<PaymentType>[.card, .transfer].contains(invoice.paymentType)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label,
                      Text(
                        " - Ref: ${invoice.bankReference}",
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

            Builder(
              builder: (context) {
                String clientLabel = "${invoice.clientId} - ${invoice.clientInfo.name}";
                if (invoice.clientId == "SALE_CLIENT") {
                  clientLabel = invoice.clientInfo.name;
                }

                return Text(
                  clientLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                );
              },
            ),

            if (invoice.clientInfo.location != null && invoice.clientInfo.location!.isNotEmpty)
              Text(
                "${invoice.clientInfo.location}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

            if (invoice.clientInfo.address != null && invoice.clientInfo.address!.isNotEmpty)
              Text(
                "${invoice.clientInfo.address}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

            Row(
              children: [
                Text(
                  "Vendedor: ${invoice.createdBy.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            if (invoice.orderInfo != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pedido No. ${invoice.orderInfo!.docNumber}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey.shade800),
                  ),
                  Text(
                    "${DateTimeTool.formatddMMyy(invoice.orderInfo!.createdAt)} ${DateTimeTool.formatHHmm(invoice.orderInfo!.createdAt)}",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blueGrey.shade700),
                  ),
                ],
              ),
              Text(
                "Tomado por: ${invoice.orderInfo!.createdBy.name}",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blueGrey.shade700),
              ),
            ],

            if (invoice.description.isNotEmpty)
              Text(
                "Observación: ${invoice.description}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
          ],
        ),
        const Divider(),
        Flexible(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Producto",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Cant.",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Precio",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: invoice.saleItems.length,
                  itemBuilder: (context, index) {
                    final saleItem = invoice.saleItems[index];
                    final rowColor = RowColorTool.getRowColor(index);
                    return Container(
                      padding: const EdgeInsets.all(4),
                      color: rowColor,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 4,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.qr_code_rounded,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      saleItem.product.code ?? "",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Text(saleItem.product.name),
                                Text(
                                  saleItem.displayUnitName,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  saleItem.formattedDisplayQuantity,
                                  textAlign: TextAlign.center,
                                ),
                                if (saleItem.bonQuantity > 0)
                                  Text(
                                    "+ ${saleItem.formattedDisplayBonQuantity} bonif.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormatter.convertFromCentsToDouble(
                                saleItem.price * saleItem.conversionFactor,
                              ).toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormatter.convertFromCentsToDouble(saleItem.subTotal).toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "SubTotal:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(invoiceSubTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Total Descuento:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(totalDiscount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(invoice.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (approvedCreditNotes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Notas de Crédito:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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
                                  size: 18,
                                  color: AppThemeTokens.purple,
                                ),
                                tooltip: "Ver Nota de Crédito",
                                onPressed: () {
                                  if (approvedCreditNotes.length == 1) {
                                    showCreditNoteViewerDialog(context, approvedCreditNotes.first);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Notas de Crédito Aprobadas"),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: approvedCreditNotes.length,
                                            itemBuilder: (_, idx) {
                                              final cn = approvedCreditNotes[idx];
                                              return ListTile(
                                                title: Text("NC #${cn.docNumber}"),
                                                trailing: Text(NumberFormatter.convertToMoneyLike(cn.total)),
                                                onTap: () {
                                                  Navigator.pop(ctx);
                                                  showCreditNoteViewerDialog(context, cn);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Cerrar"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              "- ${NumberFormatter.convertToMoneyLike(creditNotesTotal)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppThemeTokens.purple,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppThemeTokens.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Total Neto:",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppThemeTokens.success,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                NumberFormatter.convertToMoneyLike(netInvoiceTotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppThemeTokens.success,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (pendingApprovalCreditNotes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: Colors.amber.shade900),
                          const SizedBox(width: 4),
                          Text(
                            "NC pendientes de aprobación: ${pendingApprovalCreditNotes.length} (no descuenta)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (secondaryTotal != null && secondaryCurrency != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Total(${secondaryCurrency.code}):",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              secondaryTotal,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blueGrey.shade800,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
