import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/cache/image_bytes_resolver.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

/// Diálogo y generador visual para compartir el historial de abonos de una
/// factura en formato de imagen PNG.
Future<void> showInvoiceReceiptsHistoryImageDialog({
  required BuildContext context,
  required InvoiceInDb invoice,
  required List<ReceiptInDb> receipts,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _InvoiceReceiptsHistoryImageDialog(
      invoice: invoice,
      receipts: receipts,
    ),
  );
}

class _InvoiceReceiptsHistoryImageDialog extends StatefulWidget {
  final InvoiceInDb invoice;
  final List<ReceiptInDb> receipts;

  const _InvoiceReceiptsHistoryImageDialog({
    required this.invoice,
    required this.receipts,
  });

  @override
  State<_InvoiceReceiptsHistoryImageDialog> createState() => _InvoiceReceiptsHistoryImageDialogState();
}

class _InvoiceReceiptsHistoryImageDialogState extends State<_InvoiceReceiptsHistoryImageDialog> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  Uint8List? _capturedImageBytes;
  Uint8List? _logoBytes;
  bool _isGenerating = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureHistoryImage();
    });
  }

  Future<void> _captureHistoryImage() async {
    try {
      // 1. Resolver asíncronamente los bytes del logo de la sucursal
      final authState = getIt<AuthCubit>().state;
      if (authState is Authenticated) {
        _logoBytes = await authState.branch.resolveLogoBytes();
        if (mounted) setState(() {});
      }

      // 2. Esperar brevemente para asegurar que fuentes, logo e íconos se hayan pintado
      await Future.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;

      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        setState(() => _isGenerating = false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

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
    final sanitizedDocNumber = widget.invoice.docNumber
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final dateStr = DateTimeTool.formatyyyyMMdd(DateTime.now());
    return 'historial_abonos_factura_${sanitizedDocNumber}_$dateStr';
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
          text: 'Historial de Abonos - Factura #${widget.invoice.docNumber} - ${widget.invoice.clientInfo.name}',
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
              title: "Historial de Abonos",
              subtitle: "Factura #${widget.invoice.docNumber}",
              icon: Icons.receipt_long_outlined,
              accentColor: AppThemeTokens.teal,
              trailingBadge: AppStatusBadge.teal(label: "Imagen PNG"),
              onClose: () => Navigator.of(context).pop(),
            ),

            // Vista previa o indicador de carga
            Expanded(
              child: Stack(
                children: [
                  // Widget fuera de vista directa para la captura por RepaintBoundary.
                  // Envuelto en scroll horizontal para que NUNCA sea comprimido por el ancho del teléfono.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: SizedBox(
                          width: 860,
                          child: _ReceiptsHistoryVisualCard(
                            invoice: widget.invoice,
                            branch: branch,
                            logoBytes: _logoBytes,
                            receipts: widget.receipts,
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
                              "Generando historial en imagen...",
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
                  Expanded(
                    child: Text(
                      "${widget.receipts.length} recibo(s)",
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
                    onPressed: _isGenerating || _isSharing ? null : _shareImage,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share_rounded, size: 18),
                    label: const Text("Compartir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeTokens.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppThemeTokens.borderRadiusSm,
                      ),
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

/// Tarjeta visual del Historial de Abonos renderizada para la captura en imagen PNG
class _ReceiptsHistoryVisualCard extends StatelessWidget {
  final InvoiceInDb invoice;
  final BranchInDb? branch;
  final Uint8List? logoBytes;
  final List<ReceiptInDb> receipts;

  const _ReceiptsHistoryVisualCard({
    required this.invoice,
    required this.branch,
    this.logoBytes,
    required this.receipts,
  });

  int _amountAppliedToInvoice(ReceiptInDb receipt) {
    return receipt.appliedInvoices
        .where((applied) => applied.invoiceId == invoice.id)
        .fold(0, (sum, applied) => sum + applied.amountApplied);
  }

  @override
  Widget build(BuildContext context) {
    final ClientInfo client = invoice.clientInfo;
    final int totalApplied = receipts.fold<int>(
      0,
      (sum, receipt) => sum + _amountAppliedToInvoice(receipt),
    );
    final int remainingBalance = invoice.total - totalApplied;

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
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
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
                          if (branch?.email != null && branch!.email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              "Email: ${branch!.email}",
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.teal.withValues(alpha: 0.1),
                      borderRadius: AppThemeTokens.borderRadiusSm,
                      border: Border.all(
                        color: AppThemeTokens.teal.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "HISTORIAL DE ABONOS",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F766E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Factura #${invoice.docNumber}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Generado: ${DateTimeTool.formatddMMyyEs(DateTime.now())} ${DateTimeTool.formatHHmm(DateTime.now())}",
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

          // 2. Ficha de Datos del Cliente y de la Factura (Bento Container)
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
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
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
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      if (client.location != null && client.location!.isNotEmpty)
                        Text(
                          client.location!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (client.address != null && client.address!.isNotEmpty)
                        Text(
                          client.address!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FACTURA",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "#${invoice.docNumber}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Emitida: ${DateTimeTool.formatddMMyyEs(invoice.createdAt)}",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Resumen Financiero de la Factura
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCell(
                    "Total Factura",
                    invoice.total,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildSummaryCell(
                    "Total Abonos",
                    totalApplied,
                    color: const Color(0xFF0D9488),
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildSummaryCell(
                    "Saldo Restante",
                    remainingBalance,
                    color: remainingBalance > 0 ? const Color(0xFFDC2626) : const Color(0xFF0D9488),
                    isBold: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 4. Tabla de Recibos
          Text(
            "DETALLE DE ABONOS (${receipts.length})",
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
                // Cabecera de la Tabla
                Container(
                  color: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Recibo",
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
                          "Fecha/Hora",
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
                          "Método",
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
                          "Monto Aplicado",
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
                    ],
                  ),
                ),

                // Filas de Recibos
                if (receipts.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "No hay abonos registrados para esta factura.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: receipts.length,
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      final amountApplied = _amountAppliedToInvoice(receipt);

                      return Container(
                        color: RowColorTool.getRowColor(index),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "#${receipt.docNumber}",
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
                              flex: 3,
                              child: Text(
                                "${DateTimeTool.formatddMMyy(receipt.createdAt)} ${DateTimeTool.formatHHmm(receipt.createdAt)}",
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                receipt.paymentMethod.display,
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
                                  NumberFormatter.convertToMoneyLike(
                                    amountApplied,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // Total de abonos del historial
                Container(
                  color: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Total Abonos:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        NumberFormatter.convertToMoneyLike(totalApplied),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // 5. Pie de Página
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

  Widget _buildSummaryCell(
    String label,
    int amount, {
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            NumberFormatter.convertToMoneyLike(amount),
            style: TextStyle(
              fontSize: isBold ? 19 : 17,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFFE2E8F0),
    );
  }
}
