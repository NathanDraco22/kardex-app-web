import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class ImportPreviewDialog extends StatelessWidget {
  const ImportPreviewDialog({
    super.key,
    required this.title,
    required this.fileName,
    required this.fileSizeBytes,
    required this.branchName,
    required this.icon,
    required this.accentColor,
    required this.preview,
    this.warning,
  });

  final String title;
  final String fileName;
  final int fileSizeBytes;
  final String? branchName;
  final IconData icon;
  final Color accentColor;
  final ImportPreviewResult preview;
  final String? warning;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String fileName,
    required int fileSizeBytes,
    String? branchName,
    required IconData icon,
    required Color accentColor,
    required ImportPreviewResult preview,
    String? warning,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ImportPreviewDialog(
          title: title,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes,
          branchName: branchName,
          icon: icon,
          accentColor: accentColor,
          preview: preview,
          warning: warning,
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final hasErrors = !preview.isValid || preview.errors.isNotEmpty;
    final isInventory = preview.importType == "initialInventory" ||
        preview.importType == "inventory";
    final isClients = preview.importType == "clients";

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppThemeTokens.borderRadiusLg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogHeader(
              title: hasErrors
                  ? "Archivo con observaciones"
                  : "Vista previa de importación",
              subtitle: title,
              icon: hasErrors ? Icons.warning_amber_rounded : icon,
              accentColor: hasErrors ? AppThemeTokens.danger : accentColor,
              onClose: () => Navigator.of(context).pop(false),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: "Archivo",
                      value: fileName,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.data_usage_rounded,
                      label: "Tamaño",
                      value: _formatBytes(fileSizeBytes),
                    ),
                    if (branchName != null) ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        label: "Sucursal destino",
                        value: branchName!,
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      "RESUMEN DE TOTALES",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isInventory)
                      _buildInventoryTotals()
                    else if (isClients)
                      _buildClientsTotals()
                    else
                      _buildSuppliersTotals(),
                    const SizedBox(height: 18),
                    if (hasErrors)
                      _buildErrorsBanner()
                    else
                      _buildSuccessBanner(),
                    if (warning != null) ...[
                      const SizedBox(height: 14),
                      _buildWarningBanner(),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppThemeTokens.borderLight),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: preview.isValid
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(
                      preview.isValid
                          ? "Importar ahora (${preview.totalRows})"
                          : "Importación bloqueada",
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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

  Widget _buildInventoryTotals() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: "Productos",
                value: "${preview.totalRows}",
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: "Unidades totales",
                value: "${preview.totalQuantity}",
                icon: Icons.tag_rounded,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: "Inversión costo",
                value: NumberFormatter.convertToMoneyLike(preview.totalCost),
                icon: Icons.payments_outlined,
                color: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: "Venta estimada",
                value: NumberFormatter.convertToMoneyLike(preview.totalPrice),
                icon: Icons.point_of_sale_rounded,
                color: const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClientsTotals() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: "Clientes",
                value: "${preview.totalRows}",
                icon: Icons.people_outline_rounded,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: "Saldo inicial total",
                value: NumberFormatter.convertToMoneyLike(
                  preview.totalInitialBalance,
                ),
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: "Límite de crédito total",
                value: NumberFormatter.convertToMoneyLike(
                  preview.totalCreditLimit,
                ),
                icon: Icons.credit_score_rounded,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuppliersTotals() {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: "Proveedores a registrar",
            value: "${preview.totalRows}",
            icon: Icons.local_shipping_outlined,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.danger.withValues(alpha: 0.08),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(
          color: AppThemeTokens.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 20,
                color: AppThemeTokens.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Se encontraron ${preview.errors.length} errores en el archivo:",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppThemeTokens.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: preview.errors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final error = preview.errors[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          error.row > 0 ? "Fila ${error.row}" : "General",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error.message,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Corrige los errores indicados en tu archivo CSV antes de importar.",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.success.withValues(alpha: 0.08),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(
          color: AppThemeTokens.success.withValues(alpha: 0.28),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 20,
            color: AppThemeTokens.success,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Archivo verificado correctamente sin errores. "
              "Los registros están listos para ser importados a la base de datos.",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF065F46),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.warning.withValues(alpha: 0.09),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(
          color: AppThemeTokens.warning.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 19,
            color: AppThemeTokens.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning!,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.amber.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    }

    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) {
      return "${kilobytes.toStringAsFixed(1)} KB";
    }

    final megabytes = kilobytes / 1024;
    return "${megabytes.toStringAsFixed(1)} MB";
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppThemeTokens.surfaceLight,
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(color: AppThemeTokens.borderLight),
          ),
          child: Icon(icon, size: 16, color: AppThemeTokens.neutral),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
