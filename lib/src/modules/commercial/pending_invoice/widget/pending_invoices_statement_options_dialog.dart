import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/pending_invoices_statement_image_dialog.dart';
import 'package:kardex_app_front/src/tools/exports/file_save_helper.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/pending_invoices_statement_template.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';

/// Muestra las opciones de Estado de Cuenta (PDF e Imagen) para descargar o compartir.
Future<void> showPendingInvoicesStatementOptionsDialog({
  required BuildContext context,
  required ClientInDb client,
  required List<InvoiceInDb> invoices,
  required List<DevolutionInDb> devolutions,
  required List<CreditNoteInDb> creditNotes,
  BranchInDb? branch,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _PendingInvoicesStatementOptionsDialog(
      client: client,
      invoices: invoices,
      devolutions: devolutions,
      creditNotes: creditNotes,
      branch: branch,
    ),
  );
}

class _PendingInvoicesStatementOptionsDialog extends StatefulWidget {
  final ClientInDb client;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final BranchInDb? branch;

  const _PendingInvoicesStatementOptionsDialog({
    required this.client,
    required this.invoices,
    required this.devolutions,
    required this.creditNotes,
    this.branch,
  });

  @override
  State<_PendingInvoicesStatementOptionsDialog> createState() =>
      _PendingInvoicesStatementOptionsDialogState();
}

class _PendingInvoicesStatementOptionsDialogState
    extends State<_PendingInvoicesStatementOptionsDialog> {
  bool _isDownloadingPdf = false;
  bool _isSharingPdf = false;

  bool get _isPdfBusy => _isDownloadingPdf || _isSharingPdf;

  BranchInDb? _resolveBranch() {
    if (widget.branch != null) return widget.branch;
    if (getIt.isRegistered<AuthCubit>()) {
      final authState = getIt<AuthCubit>().state;
      if (authState is Authenticated) return authState.branch;
    }
    return null;
  }

  Future<Uint8List> _buildPdfBytes() async {
    final template = PendingInvoicesStatementPdfTemplate(
      client: widget.client,
      branch: _resolveBranch(),
      invoices: widget.invoices,
      devolutions: widget.devolutions,
      creditNotes: widget.creditNotes,
    );
    final doc = await template.buildDocument();
    return doc.save();
  }

  String _fileName() {
    return FileSaveHelper.buildStatementFileName(
      prefix: 'estado_cuenta',
      clientName: widget.client.name,
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloadingPdf = true);
    try {
      final bytes = await _buildPdfBytes();
      await FileSaveHelper.saveBytes(
        baseName: _fileName(),
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
        dialogTitle: 'Guardar Estado de Cuenta (PDF)',
      );
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: const Text('PDF guardado'),
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Error al descargar PDF'),
        description: Text(e.toString()),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  Future<void> _sharePdf() async {
    setState(() => _isSharingPdf = true);
    try {
      final bytes = await _buildPdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_fileName()}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Error al compartir PDF'),
        description: Text(e.toString()),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _isSharingPdf = false);
    }
  }

  void _openImagePreview() {
    final parentNavigator = Navigator.of(context);
    parentNavigator.pop();
    showPendingInvoicesStatementImageDialog(
      context: parentNavigator.context,
      client: widget.client,
      invoices: widget.invoices,
      devolutions: widget.devolutions,
      creditNotes: widget.creditNotes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDialogHeader(
              title: 'Estado de Cuenta',
              icon: Icons.description_outlined,
              accentColor: AppThemeTokens.indigo,
              trailingBadge: AppStatusBadge.indigo(
                label: '${widget.invoices.length} factura(s)',
              ),
              onClose: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cliente: ${widget.client.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige el formato para descargar o compartir el estado de cuenta.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormatOptionCard(
                    icon: Icons.picture_as_pdf_outlined,
                    accentColor: AppThemeTokens.danger,
                    title: 'PDF',
                    subtitle: 'Documento A4 multipágina listo para imprimir o enviar.',
                    actions: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isPdfBusy ? null : _downloadPdf,
                            icon: _isDownloadingPdf
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Descargar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppThemeTokens.borderRadiusSm,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPdfBusy ? null : _sharePdf,
                            icon: _isSharingPdf
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Compartir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeTokens.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppThemeTokens.borderRadiusSm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FormatOptionCard(
                    icon: Icons.image_outlined,
                    accentColor: AppThemeTokens.indigo,
                    title: 'Imagen',
                    subtitle: 'Comprobante visual PNG con vista previa para descargar o compartir.',
                    onTap: _isPdfBusy ? null : _openImagePreview,
                    actions: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isPdfBusy ? null : _openImagePreview,
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('Ver, Descargar o Compartir'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppThemeTokens.borderRadiusSm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOptionCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final Widget actions;
  final VoidCallback? onTap;

  const _FormatOptionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: AppThemeTokens.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppThemeTokens.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(color: AppThemeTokens.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: AppThemeTokens.borderRadiusSm,
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}
