import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_credit_note_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/printers/credit_note_printer.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> showCreditNoteViewerDialog(BuildContext context, CreditNoteInDb creditNote) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _CreditNoteViewer(
          creditNote: creditNote,
          branch: currentBranch,
          onShare: () => shareCreditNote(creditNote, currentBranch, paperSize: paperSize),
          onPrint: () => printCreditNote(creditNote, currentBranch, paperSize: paperSize),
          onExportPdf: () async {
            final template = SingleCreditNoteTemplate(creditNote: creditNote, branch: currentBranch);
            await PdfExportTool.export(template, fileName: "nota_credito_${creditNote.docNumber}.pdf");
          },
        );
      },
    ),
  );
}

Future<void> showCreditNoteViewerDialogFromId(BuildContext context, String creditNoteId) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<CreditNoteInDb?>(
          future: context.read<CreditNotesRepository>().getCreditNoteById(creditNoteId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(title: const Text("Cargando Nota...")),
                body: AppSkeletonLoader.cards(count: 3),
              );
            }

            if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(title: const Text("Nota de Crédito")),
                body: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: "Error al cargar la nota de crédito",
                  subtitle: asyncSnapshot.error?.toString() ?? "Documento no encontrado",
                  accentColor: AppThemeTokens.danger,
                ),
              );
            }

            final creditNote = asyncSnapshot.data!;

            return _CreditNoteViewer(
              creditNote: creditNote,
              branch: currentBranch,
              onShare: () => shareCreditNote(creditNote, currentBranch, paperSize: paperSize),
              onPrint: () => printCreditNote(creditNote, currentBranch, paperSize: paperSize),
              onExportPdf: () async {
                final template = SingleCreditNoteTemplate(creditNote: creditNote, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "nota_credito_${creditNote.docNumber}.pdf");
              },
            );
          },
        );
      },
    ),
  );
}

class _CreditNoteViewer extends StatelessWidget {
  const _CreditNoteViewer({
    required this.creditNote,
    required this.branch,
    this.onShare,
    this.onPrint,
    this.onExportPdf,
  });

  final CreditNoteInDb creditNote;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final isDevolution = creditNote.type == CreditNoteType.devolution;
    final themeColor = isDevolution ? AppThemeTokens.indigo : AppThemeTokens.teal;
    final totalFormatted = NumberFormatter.convertToMoneyLike(creditNote.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Nota de Crédito #${creditNote.docNumber}",
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        actions: [
          IconButton(
            tooltip: "Exportar PDF (A4)",
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            tooltip: "Compartir Nota de Crédito",
            onPressed: onShare,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Nota de Crédito",
            onPressed: onPrint,
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, totalFormatted),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppThemeTokens.borderRadiusLg,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: AppThemeTokens.subtleCardShadow(),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- CABECERA ESTILO VOUCHER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: themeColor.withValues(alpha: 0.12),
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  border: Border.all(color: themeColor.withValues(alpha: 0.25)),
                                ),
                                child: Icon(
                                  isDevolution ? Icons.assignment_return_rounded : Icons.monetization_on_rounded,
                                  color: themeColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Folio: #${creditNote.docNumber}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Sucursal: ${branch.name}",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateTimeTool.formatddMMyy(creditNote.createdAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ÚLTIMA ROW DE LA CABECERA: Badges con Wrap
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (isDevolution)
                          AppStatusBadge.indigo(label: creditNote.type.display)
                        else
                          AppStatusBadge.teal(label: creditNote.type.display),
                        _buildStatusBadge(creditNote.status),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // --- INFORMACIÓN DEL CLIENTE Y DETALLES ---
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 16, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                "Cliente: ${creditNote.clientInfo.name}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          if (isDevolution && creditNote.originalInvoiceDocNumber.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Text(
                                  "Factura de Origen: #${creditNote.originalInvoiceDocNumber}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (creditNote.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              "Motivo: ${creditNote.description}",
                              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                            ),
                          ],
                          if (creditNote.appliedReceiptDocNumber != null &&
                              creditNote.appliedReceiptDocNumber!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemeTokens.success.withValues(alpha: 0.1),
                                borderRadius: AppThemeTokens.borderRadiusSm,
                                border: Border.all(color: AppThemeTokens.success.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 15, color: AppThemeTokens.success),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Aplicada en Recibo #${creditNote.appliedReceiptDocNumber}",
                                    style: const TextStyle(
                                      color: AppThemeTokens.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (creditNote.status == CreditNoteStatus.emitted) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemeTokens.warning.withValues(alpha: 0.12),
                                borderRadius: AppThemeTokens.borderRadiusSm,
                                border: Border.all(color: AppThemeTokens.warning.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: AppThemeTokens.warning),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Emitida y pendiente de aprobación. No afecta inventario ni descuenta de la factura hasta ser aprobada.",
                                      style: TextStyle(
                                        color: AppThemeTokens.warning,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (creditNote.approvedBy != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemeTokens.info.withValues(alpha: 0.1),
                                borderRadius: AppThemeTokens.borderRadiusSm,
                                border: Border.all(color: AppThemeTokens.info.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_outlined, size: 16, color: AppThemeTokens.info),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Aprobada por ${creditNote.approvedBy!.name}${creditNote.approvedAt != null ? ' el ${DateTimeTool.formatddMMyy(creditNote.approvedAt!)}' : ''}",
                                    style: const TextStyle(
                                      color: AppThemeTokens.info,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (creditNote.status == CreditNoteStatus.rejected) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppThemeTokens.danger.withValues(alpha: 0.1),
                                borderRadius: AppThemeTokens.borderRadiusSm,
                                border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.block_rounded, size: 16, color: AppThemeTokens.danger),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Rechazada por ${creditNote.rejectedBy?.name ?? 'Usuario'}",
                                        style: const TextStyle(
                                          color: AppThemeTokens.danger,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (creditNote.rejectionReason != null && creditNote.rejectionReason!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      "Motivo: ${creditNote.rejectionReason}",
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- DETALLE DE ARTÍCULOS O CONCEPTO ---
                    if (isDevolution && creditNote.returnedItems.isNotEmpty) ...[
                      const Text(
                        "ARTÍCULOS DEVUELTOS",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tabla sticky-style con header sutil
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                "PRODUCTO",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "CANTIDAD",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                "SUBTOTAL",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: creditNote.returnedItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final item = creditNote.returnedItems[index];
                          final itemSubtotalFormatted = NumberFormatter.convertToMoneyLike(item.subTotal);
                          final displayQty = item.formattedDisplayQuantity;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (item.displayUnitName.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.displayUnitName,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        displayQty,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      if (item.bonQuantity > 0)
                                        Text(
                                          "+ ${item.formattedDisplayBonQuantity} bonif.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    itemSubtotalFormatted,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppThemeTokens.teal.withValues(alpha: 0.05),
                          borderRadius: AppThemeTokens.borderRadiusMd,
                          border: Border.all(color: AppThemeTokens.teal.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppThemeTokens.teal, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                creditNote.description.isNotEmpty
                                    ? creditNote.description
                                    : "Nota de crédito generada por monto para amortizar saldos o aplicar descuentos comerciales.",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // --- TOTAL SUMMARY CARD BENTO ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.07),
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Saldo a Favor",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Emitido por ${creditNote.createdBy.name}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            totalFormatted,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: themeColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context, String totalFormatted) {
    if (creditNote.status == CreditNoteStatus.emitted) {
      return BottomAppBar(
        height: 70,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeTokens.danger,
                side: const BorderSide(color: AppThemeTokens.danger),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppThemeTokens.borderRadiusMd,
                ),
              ),
              onPressed: () => _handleReject(context),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text(
                "Rechazar",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppThemeTokens.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppThemeTokens.borderRadiusMd,
                ),
              ),
              onPressed: () => _handleApprove(context),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text(
                "Aprobar Nota",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    if (creditNote.status == CreditNoteStatus.approved ||
        creditNote.status == CreditNoteStatus.confirmed ||
        creditNote.status == CreditNoteStatus.open) {
      return BottomAppBar(
        height: 68,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        child: Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeTokens.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppThemeTokens.borderRadiusMd,
              ),
            ),
            onPressed: () => _handleDelete(context, totalFormatted),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: const Text(
              "Borrar Nota de Crédito",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }

  Future<void> _handleApprove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Aprobar Nota de Crédito"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Confirmas la aprobación de la Nota de Crédito #${creditNote.docNumber}?",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (creditNote.type == CreditNoteType.devolution) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: Colors.blue.shade800, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Los artículos devueltos se reingresarán automáticamente al stock disponible en el Kárdex.",
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomSlider(
                    hintText: "Desliza para Aprobar",
                    hintIcon: Icons.verified_outlined,
                    sliderColor: AppThemeTokens.success,
                    sliderText: "Aprobar",
                    onSubmit: () => Navigator.of(dialogCtx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return;
    final currentUser = authState.session.user;
    final userInfo = UserInfo(id: currentUser.id, name: currentUser.username);

    try {
      LoadingDialogManager.showLoadingDialog(context);
      await context.read<CreditNotesRepository>().approveCreditNote(creditNote.id, userInfo);
      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);
      Navigator.pop(context);
      await DialogManager.showInfoDialog(context, "Nota de crédito aprobada correctamente.");
    } catch (e) {
      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);
      await DialogManager.showErrorDialog(context, "Error al aprobar: $e");
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Rechazar Nota de Crédito"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ingresa el motivo del rechazo de la Nota de Crédito #${creditNote.docNumber}:"),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Motivo del rechazo...",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppThemeTokens.danger),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.of(dialogCtx).pop(true);
            },
            child: const Text("Rechazar"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return;
    final currentUser = authState.session.user;
    final userInfo = UserInfo(id: currentUser.id, name: currentUser.username);

    try {
      LoadingDialogManager.showLoadingDialog(context);
      await context.read<CreditNotesRepository>().rejectCreditNote(
        creditNote.id,
        userInfo,
        reasonController.text.trim(),
      );
      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);
      Navigator.pop(context);
      await DialogManager.showInfoDialog(context, "Nota de crédito rechazada.");
    } catch (e) {
      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);
      await DialogManager.showErrorDialog(context, "Error al rechazar: $e");
    }
  }

  Future<void> _handleDelete(BuildContext context, String totalFormatted) async {
    final isDev = creditNote.type == CreditNoteType.devolution;
    final warningMsg = isDev
        ? "Se anulará la nota de crédito #${creditNote.docNumber} y los artículos devueltos se descontarán del inventario físico para revertir la operación."
        : "Se anulará la nota de crédito #${creditNote.docNumber} por importe de $totalFormatted.";

    final confirmed = await DialogManager.slideToConfirmDeleteActionDialog(
      context,
      warningMsg,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      LoadingDialogManager.showLoadingDialog(context);
      await context.read<CreditNotesRepository>().deleteCreditNote(creditNote.id);
      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);
      Navigator.pop(context);
      await DialogManager.showInfoDialog(context, "Nota de crédito eliminada correctamente.");
    } catch (e) {
      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);
      await DialogManager.showErrorDialog(context, "Error al eliminar: $e");
    }
  }

  Widget _buildStatusBadge(CreditNoteStatus status) {
    switch (status) {
      case CreditNoteStatus.emitted:
        return AppStatusBadge.warning(
          label: status.display,
          icon: Icons.schedule_rounded,
        );
      case CreditNoteStatus.approved:
        return AppStatusBadge.info(
          label: status.display,
          icon: Icons.verified_outlined,
        );
      case CreditNoteStatus.rejected:
        return AppStatusBadge.danger(
          label: status.display,
          icon: Icons.block_rounded,
        );
      case CreditNoteStatus.applied:
        return AppStatusBadge.success(
          label: status.display,
          icon: Icons.check_circle_outline_rounded,
        );
      case CreditNoteStatus.confirmed:
        return AppStatusBadge.info(
          label: status.display,
          icon: Icons.verified_outlined,
        );
      case CreditNoteStatus.cancelled:
        return AppStatusBadge.danger(
          label: status.display,
          icon: Icons.cancel_outlined,
        );
      case CreditNoteStatus.open:
        return AppStatusBadge.info(
          label: status.display,
          icon: Icons.pending_actions_rounded,
        );
    }
  }
}
