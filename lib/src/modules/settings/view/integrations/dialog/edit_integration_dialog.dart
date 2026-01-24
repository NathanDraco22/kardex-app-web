import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/integration/integration_model.dart';

class EditIntegrationDialog extends StatefulWidget {
  final IntegrationModel integration;
  final Function(UpdateIntegration) onSave;

  const EditIntegrationDialog({
    super.key,
    required this.integration,
    required this.onSave,
  });

  @override
  State<EditIntegrationDialog> createState() => _EditIntegrationDialogState();
}

class _EditIntegrationDialogState extends State<EditIntegrationDialog> {
  late TextEditingController _reportIdController;
  late TextEditingController _adjustmentIdController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _reportIdController = TextEditingController(
      text: widget.integration.telegram.reportId,
    );
    _adjustmentIdController = TextEditingController(
      text: widget.integration.telegram.adjustmentId,
    );
    _isActive = widget.integration.telegram.isActive;
  }

  @override
  void dispose() {
    _reportIdController.dispose();
    _adjustmentIdController.dispose();
    super.dispose();
  }

  void _onSave() {
    final updatedTelegram = widget.integration.telegram.copyWith(
      isActive: _isActive,
      reportId: _reportIdController.text,
      adjustmentId: _adjustmentIdController.text,
    );

    widget.onSave(UpdateIntegration(telegram: updatedTelegram));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Integración"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text("Activo"),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            TextField(
              enabled: _isActive,
              controller: _reportIdController,
              decoration: const InputDecoration(labelText: "Report ID"),
            ),
            const SizedBox(height: 10),
            TextField(
              enabled: _isActive,
              controller: _adjustmentIdController,
              decoration: const InputDecoration(labelText: "Adjustment ID"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
