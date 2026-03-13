import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';

Future<void> showLocalPrinterSettingsDialog(BuildContext context) async {
  final currentSize = await PrintManager.getLocalPaperSize();

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return _LocalPrinterSettingsDialog(initialSize: currentSize);
    },
  );
}

class _LocalPrinterSettingsDialog extends StatefulWidget {
  final PaperSize initialSize;

  const _LocalPrinterSettingsDialog({required this.initialSize});

  @override
  State<_LocalPrinterSettingsDialog> createState() => _LocalPrinterSettingsDialogState();
}

class _LocalPrinterSettingsDialogState extends State<_LocalPrinterSettingsDialog> {
  late PaperSize _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
  }

  Future<void> _saveSettings() async {
    await PrintManager.saveLocalPaperSize(_selectedSize);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configuración de Impresora Local'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Seleccione el tamaño del papel térmico a usar por defecto en este dispositivo:'),
          const SizedBox(height: 16),
          RadioListTile<PaperSize>(
            title: const Text('80 mm'),
            value: PaperSize.mm80,
            groupValue: _selectedSize,
            onChanged: (PaperSize? value) {
              if (value != null) {
                setState(() {
                  _selectedSize = value;
                });
              }
            },
          ),
          RadioListTile<PaperSize>(
            title: const Text('58 mm'),
            value: PaperSize.mm58,
            groupValue: _selectedSize,
            onChanged: (PaperSize? value) {
              if (value != null) {
                setState(() {
                  _selectedSize = value;
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
