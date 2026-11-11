import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:share_plus/share_plus.dart';

/// Diálogo y generador visual para compartir el estado de cuenta o liquidación de facturas en formato de imagen PNG.
Future<void> showPendingInvoicesStatementImageDialog({
  required BuildContext context,
  required ClientInDb client,
  required List<InvoiceInDb> invoices,
  required List<DevolutionInDb> devolutions,
  required List<CreditNoteInDb> creditNotes,
  String? title,
  String? badgeText,
  String? filePrefix,
  String? tableTitle,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _PendingInvoicesStatementImageDialog(
      client: client,
      invoices: invoices,
      devolutions: devolutions,
      creditNotes: creditNotes,
      title: title ?? "Estado de Cuenta del Cliente",
      badgeText: badgeText ?? "ESTADO DE CUENTA",
      filePrefix: filePrefix ?? "estado_cuenta",
      tableTitle: tableTitle ?? "DETALLE DE FACTURAS PENDIENTES",
    ),
  );
}

class _PendingInvoicesStatementImageDialog extends StatefulWidget {
  final ClientInDb client;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final String title;
  final String badgeText;
  final String filePrefix;
  final String tableTitle;

  const _PendingInvoicesStatementImageDialog({
    required this.client,
    required this.invoices,
    required this.devolutions,
    required this.creditNotes,
    required this.title,
    required this.badgeText,
    required this.filePrefix,
    required this.tableTitle,
  });

  @override
  State<_PendingInvoicesStatementImageDialog> createState() =>
      _PendingInvoicesStatementImageDialogState();
}

class _PendingInvoicesStatementImageDialogState
    extends State<_PendingInvoicesStatementImageDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  Uint8List? _capturedImageBytes;
  Uint8List? _logoBytes;
  bool _isGenerating = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureStatementImage();
    });
  }

  Future<void> _captureStatementImage() async {
    try {
      // 1. Resolver asíncronamente los bytes del logo de la sucursal desde imageUrl
      final authState = getIt<AuthCubit>().state;
      if (authState is Authenticated) {
        final branch = authState.branch;
        _logoBytes = await branch.resolveLogoBytes();
        if (mounted) setState(() {});
      }

      // 2. Esperar brevemente para asegurar que fuentes, logo e íconos se hayan pintado
      await Future.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;

      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        setState(() => _isGenerating = false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        setState(() {
          _capturedImageBytes = byteData.buffer.asUint8List();
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _generateFileName() {
    final sanitizedClient = widget.client.name
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final dateStr = DateTimeTool.formatyyyyMMdd(DateTime.now());
    return '${widget.filePrefix}_${sanitizedClient}_$dateStr';
  }

  Future<void> _shareImage() async {
    if (_capturedImageBytes == null) return;
    setState(() => _isSharing = true);
    try {
      final fileName = '${_generateFileName()}.png';
      final xFile = XFile.fromData(
        _capturedImageBytes!,
        name: fileName,
        mimeType: 'image/png',
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: '${widget.title} - ${widget.client.name}',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    BranchInDb? branch;
    final authState = getIt<AuthCubit>().state;
    if (authState is Authenticated) {
      branch = authState.branch;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 820),
        child: Column(
          children: [
            AppDialogHeader(
              title: widget.title,
              icon: Icons.image_outlined,
              accentColor: AppThemeTokens.indigo,
              trailingBadge: AppStatusBadge.indigo(label: "Imagen PNG"),
              onClose: () => Navigator.of(context).pop(),
            ),

            // Vista previa o indicador de carga
            Expanded(
              child: Stack(
                children: [
                  // Widget fuera de vista directa para la captura por RepaintBoundary
                  // Envuelto en scroll horizontal para que NUNCA sea comprimido por el ancho del teléfono
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: SizedBox(
                          width: 860,
                          child: _StatementVisualCard(
                            client: widget.client,
                            branch: branch,
                            logoBytes: _logoBytes,
                            invoices: widget.invoices,
                            devolutions: widget.devolutions,
                            creditNotes: widget.creditNotes,
                            badgeText: widget.badgeText,
                            tableTitle: widget.tableTitle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Si la imagen ya fue generada, mostramos la previsualización nítida
                  if (!_isGenerating && _capturedImageBytes != null)
                    Container(
                      color: Colors.grey.shade100,
                      width: double.infinity,
                      height: double.infinity,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: AppThemeTokens.dialogShadow(),
                                borderRadius: AppThemeTokens.borderRadiusMd,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.memory(
                                _capturedImageBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Indicador de carga mientras se rasteriza
                  if (_isGenerating)
                    Container(
                      color: Colors.white.withValues(alpha: 0.95),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              "Generando comprobante en imagen...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppThemeTokens.borderLight),

            // Barra de Acciones Inferior: Conteo a la izquierda y botón Compartir a la derecha
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    "${widget.invoices.length} factura(s)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  PrimaryMenuButton(
                    onPressed: _isGenerating || _isSharing ? null : _shareImage,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.share_rounded, size: 18),
                    label: const Text("Compartir"),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

/// Tarjeta visual del Estado de Cuenta / Liquidación renderizada para la captura en imagen PNG
class _StatementVisualCard extends StatelessWidget {
  final ClientInDb client;
  final BranchInDb? branch;
  final Uint8List? logoBytes;
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final String badgeText;
  final String tableTitle;

  const _StatementVisualCard({
    required this.client,
    required this.branch,
    this.logoBytes,
    required this.invoices,
    required this.devolutions,
    required this.creditNotes,
    required this.badgeText,
    required this.tableTitle,
  });

  @override
  Widget build(BuildContext context) {
    final int totalInvoices = invoices.fold(0, (sum, inv) => sum + inv.totalRemaining);
    final int totalDevolutions = devolutions.fold(0, (sum, d) => sum + d.total);
    final int totalCreditNotes = creditNotes.fold(0, (sum, cn) => sum + cn.total);
    final int netTotal = (totalInvoices - totalDevolutions - totalCreditNotes) > 0
        ? (totalInvoices - totalDevolutions - totalCreditNotes)
        : 0;

    return Container(
      width: 860,
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Membrete y Encabezado con Logo de Sucursal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (logoBytes != null && logoBytes!.isNotEmpty) ...[
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.memory(
                          logoBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch?.name ?? "KARDEX APP",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (branch?.address != null && branch!.address.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              branch!.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          if (branch?.phone != null && branch!.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              "Tel: ${branch!.phone}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.indigo.withValues(alpha: 0.1),
                      borderRadius: AppThemeTokens.borderRadiusSm,
                      border: Border.all(
                        color: AppThemeTokens.indigo.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppThemeTokens.indigo,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Fecha: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1.5, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 18),

          // 2. Ficha de Datos del Cliente (Bento Container)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CLIENTE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (client.cardId != null && client.cardId!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          "ID / Cédula: ${client.cardId}",
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CONTACTO Y DIRECCIÓN",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (client.phone != null && client.phone!.isNotEmpty)
                        Text(
                          "Tel: ${client.phone}",
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                        ),
                      if (client.location != null && client.location!.isNotEmpty)
                        Text(
                          client.location!,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 3. Tabla de Facturas
          Text(
            "$tableTitle (${invoices.length})",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: AppThemeTokens.borderRadiusSm,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Cabecera de la Tabla: Anchos calibrados y sin partición de texto
                Container(
                  color: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Factura",
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Fecha",
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Total Factura",
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Abonos",
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "A Favor (NC/Dev)",
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Saldo Pendiente",
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filas de Facturas: Espaciosas, sin cortes de líneas y blindadas para números grandes
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final inv = invoices[index];
                    final targetDev = devolutions.where((d) => d.originalInvoiceId == inv.id).toList();
                    final targetCn = creditNotes.where((cn) => cn.invoiceId == inv.id || (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == inv.docNumber)).toList();

                    final devTotal = targetDev.fold(0, (sum, d) => sum + d.total);
                    final cnTotal = targetCn.fold(0, (sum, c) => sum + c.total);
                    final discounts = devTotal + cnTotal;
                    final remaining = inv.totalRemaining - discounts;

                    return Container(
                      color: RowColorTool.getRowColor(index),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "#${inv.docNumber}",
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              DateTimeTool.formatddMMyyEs(inv.createdAt),
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                NumberFormatter.convertToMoneyLike(inv.total),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                NumberFormatter.convertToMoneyLike(inv.amountPaid),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF0D9488),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                discounts > 0 ? "-${NumberFormatter.convertToMoneyLike(discounts)}" : "0.00",
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: discounts > 0 ? const Color(0xFF8B5CF6) : Colors.grey.shade500,
                                  fontWeight: discounts > 0 ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                NumberFormatter.convertToMoneyLike(remaining),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Sección de Notas de Crédito Activas Generales
          if (creditNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF9FE),
                borderRadius: AppThemeTokens.borderRadiusSm,
                border: Border.all(color: const Color(0xFFE9D8FD), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 18, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "El cliente cuenta con ${creditNotes.length} Nota(s) de Crédito a favor por un total de ${NumberFormatter.convertToMoneyLike(totalCreditNotes)}.",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B21A8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          // 5. Resumen Financiero Total
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 360,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: AppThemeTokens.borderRadiusMd,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                ),
                child: Column(
                  children: [
                    _buildTotalRow("Subtotal Facturas:", NumberFormatter.convertToMoneyLike(totalInvoices)),
                    if (totalDevolutions > 0)
                      _buildTotalRow(
                        "Total Devoluciones:",
                        "-${NumberFormatter.convertToMoneyLike(totalDevolutions)}",
                        valueColor: Colors.orange.shade800,
                      ),
                    if (totalCreditNotes > 0)
                      _buildTotalRow(
                        "Notas de Crédito a Favor:",
                        "-${NumberFormatter.convertToMoneyLike(totalCreditNotes)}",
                        valueColor: const Color(0xFF7C3AED),
                      ),
                    const Divider(height: 16, thickness: 1, color: Color(0xFFCBD5E1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "NETO A PAGAR:",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(netTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // 6. Pie de Página con Espaciado Adecuado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Kardex App • Comprobante Informativo de Cuentas por Cobrar",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Página 1 de 1",
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
