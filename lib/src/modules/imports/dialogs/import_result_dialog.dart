import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class ImportResultDialog extends StatelessWidget {
  const ImportResultDialog._({
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.importedCount,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final int? importedCount;

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required ImportResult result,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ImportResultDialog._(
          title: title,
          message: result.message,
          icon: Icons.check_rounded,
          accentColor: AppThemeTokens.success,
          importedCount: result.importedCount,
        );
      },
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ImportResultDialog._(
          title: "No se pudo importar",
          message: message,
          icon: Icons.error_outline_rounded,
          accentColor: AppThemeTokens.danger,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = importedCount != null;
    final countLabel = importedCount == 1 ? "1 registro importado" : "$importedCount registros importados";

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppThemeTokens.borderRadiusLg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogHeader(
              title: title,
              subtitle: isSuccess ? "Los datos fueron procesados" : "Revisa el archivo",
              icon: icon,
              accentColor: accentColor,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(icon, color: accentColor, size: 28),
                    ),
                    const SizedBox(height: 14),
                    if (isSuccess) ...[
                      AppStatusBadge(
                        label: countLabel,
                        color: accentColor,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.45,
                      ),
                    ),
                    if (!isSuccess) ...[
                      const SizedBox(height: 14),
                      Text(
                        "Revisa que el archivo tenga las columnas indicadas en "
                        "la plantilla y que los valores numéricos sean válidos.",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
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
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Cerrar"),
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
