import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestCancelResult {
  const AdjustmentRequestCancelResult(this.reason);

  final String? reason;
}

Future<bool> showApproveAdjustmentRequestDialog(
  BuildContext context, {
  required AdjustmentRequestInDb request,
}) async {
  final hasSurplus = request.items.any((item) => item.difference > 0);
  final hasShortage = request.items.any((item) => item.difference < 0);
  final generatesTwoDocuments = hasSurplus && hasShortage;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(Icons.verified_outlined, color: AppThemeTokens.success, size: 34),
        title: const Text('Aprobar solicitud de ajuste'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Se aplicará la diferencia registrada al crear la solicitud ${request.docNumber}. '
                'Esta acción actualizará las existencias de la sucursal y no se puede deshacer.',
                style: const TextStyle(fontSize: 13.5, height: 1.4),
              ),
              if (generatesTwoDocuments) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppThemeTokens.warning.withValues(alpha: 0.08),
                    borderRadius: AppThemeTokens.borderRadiusMd,
                    border: Border.all(color: AppThemeTokens.warning.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: AppThemeTokens.warning),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La solicitud tiene sobrantes y faltantes: se generarán dos documentos, '
                          'una entrada por ajuste y una salida por ajuste.',
                          style: TextStyle(fontSize: 12.5, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              CustomSlider(
                hintText: 'Desliza para Aprobar',
                hintIcon: Icons.verified_outlined,
                sliderColor: AppThemeTokens.success,
                sliderText: 'Aprobar',
                onSubmit: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

Future<AdjustmentRequestCancelResult?> showCancelAdjustmentRequestDialog(
  BuildContext context, {
  required AdjustmentRequestInDb request,
}) {
  return showDialog<AdjustmentRequestCancelResult>(
    context: context,
    builder: (context) => _CancelAdjustmentRequestDialog(request: request),
  );
}

class _CancelAdjustmentRequestDialog extends StatefulWidget {
  const _CancelAdjustmentRequestDialog({required this.request});

  final AdjustmentRequestInDb request;

  @override
  State<_CancelAdjustmentRequestDialog> createState() => _CancelAdjustmentRequestDialogState();
}

class _CancelAdjustmentRequestDialogState extends State<_CancelAdjustmentRequestDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.cancel_outlined, color: AppThemeTokens.danger, size: 34),
      title: const Text('Cancelar solicitud de ajuste'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La solicitud ${widget.request.docNumber} quedará cancelada y no podrá aprobarse. '
              'Puedes registrar un motivo para dejarlo documentado.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _reasonController,
              autofocus: true,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ej. Conteo incorrecto, solicitud duplicada...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppThemeTokens.danger),
          onPressed: () {
            final reason = _reasonController.text.trim();
            Navigator.of(context).pop(
              AdjustmentRequestCancelResult(reason.isEmpty ? null : reason),
            );
          },
          icon: const Icon(Icons.cancel_rounded, size: 18),
          label: const Text('Cancelar solicitud'),
        ),
      ],
    );
  }
}
