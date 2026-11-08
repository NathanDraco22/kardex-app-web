import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class ImportConfirmationDialog extends StatelessWidget {
  const ImportConfirmationDialog({
    super.key,
    required this.title,
    required this.fileName,
    required this.fileSizeBytes,
    required this.branchName,
    required this.icon,
    required this.accentColor,
    this.warning,
  });

  final String title;
  final String fileName;
  final int fileSizeBytes;
  final String? branchName;
  final IconData icon;
  final Color accentColor;
  final String? warning;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String fileName,
    required int fileSizeBytes,
    String? branchName,
    required IconData icon,
    required Color accentColor,
    String? warning,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ImportConfirmationDialog(
          title: title,
          fileName: fileName,
          fileSizeBytes: fileSizeBytes,
          branchName: branchName,
          icon: icon,
          accentColor: accentColor,
          warning: warning,
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppThemeTokens.borderRadiusLg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogHeader(
              title: "Confirmar importación",
              subtitle: title,
              icon: icon,
              accentColor: accentColor,
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
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.data_usage_rounded,
                      label: "Tamaño",
                      value: _formatBytes(fileSizeBytes),
                    ),
                    if (branchName != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        label: "Sucursal destino",
                        value: branchName!,
                      ),
                    ],
                    if (warning != null) ...[
                      const SizedBox(height: 18),
                      Container(
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
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      "Los registros se crearán de forma permanente. "
                      "Verifica el archivo y la sucursal antes de continuar.",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
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
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text("Importar ahora"),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppThemeTokens.surfaceLight,
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(color: AppThemeTokens.borderLight),
          ),
          child: Icon(icon, size: 18, color: AppThemeTokens.neutral),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
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
