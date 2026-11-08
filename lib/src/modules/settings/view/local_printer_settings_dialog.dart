import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/src/services/thermal_printer/thermal_printer_types.dart';
import 'package:kardex_app_front/src/services/thermal_printer_service.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

Future<void> showLocalPrinterSettingsDialog(BuildContext context) async {
  if (kIsWeb) {
    await DialogManager.showInfoDialog(
      context,
      "La impresión térmica directa solo está disponible en escritorio y móvil.",
    );
    return;
  }

  final currentSize = await PrintManager.getLocalPaperSize();
  final isDirect = await PrintManager.getIsDirectPrintEnabled();
  final savedPrinter = await PrintManager.getSavedPrinter();
  final autoCut = await PrintManager.getAutoCutEnabled();
  final invertColor = await PrintManager.getInvertColorEnabled();
  final dithering = await PrintManager.getDitheringEnabled();

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return _LocalPrinterSettingsDialog(
        initialSize: currentSize,
        initialIsDirect: isDirect,
        initialPrinter: savedPrinter,
        initialAutoCut: autoCut,
        initialInvertColor: invertColor,
        initialDithering: dithering,
      );
    },
  );
}

class _LocalPrinterSettingsDialog extends StatefulWidget {
  final PaperSize initialSize;
  final bool initialIsDirect;
  final Printer? initialPrinter;
  final bool initialAutoCut;
  final bool initialInvertColor;
  final bool initialDithering;

  const _LocalPrinterSettingsDialog({
    required this.initialSize,
    required this.initialIsDirect,
    this.initialPrinter,
    required this.initialAutoCut,
    required this.initialInvertColor,
    required this.initialDithering,
  });

  @override
  State<_LocalPrinterSettingsDialog> createState() => _LocalPrinterSettingsDialogState();
}

class _LocalPrinterSettingsDialogState extends State<_LocalPrinterSettingsDialog> {
  late PaperSize _selectedSize;
  late bool _isDirectPrint;
  late bool _autoCut;
  late bool _invertColor;
  late bool _dithering;
  Printer? _selectedPrinter;

  final ThermalPrinterService _printerService = getIt<ThermalPrinterService>();
  StreamSubscription<List<Printer>>? _devicesSubscription;
  List<Printer> _discoveredPrinters = [];
  bool _isScanning = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
    _isDirectPrint = widget.initialIsDirect;
    _selectedPrinter = widget.initialPrinter;
    _autoCut = widget.initialAutoCut;
    _invertColor = widget.initialInvertColor;
    _dithering = widget.initialDithering;

    _devicesSubscription = _printerService.devicesStream.listen((printers) {
      if (mounted) {
        setState(() {
          // Filtrar impresoras sin nombre para una lista limpia
          _discoveredPrinters = printers
              .whereType<Printer>()
              .where((p) => (p.name?.trim().isNotEmpty ?? false))
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    if (_isScanning) {
      _printerService.stopScan();
    }
    super.dispose();
  }

  Future<void> _toggleScan() async {
    if (_isScanning) {
      await _printerService.stopScan();
      if (mounted) setState(() => _isScanning = false);
    } else {
      if (mounted) {
        setState(() {
          _isScanning = true;
          _discoveredPrinters.clear();
        });
      }
      await _printerService.startScan();
    }
  }

  Future<void> _testPrint() async {
    if (_selectedPrinter == null) return;
    setState(() => _isTesting = true);

    final success = await _printerService.printTestTicket(
      printer: _selectedPrinter!,
      paperSize: _selectedSize,
      autoCut: _autoCut,
    );

    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '¡Ticket de prueba impreso con éxito!'
                : 'No se pudo imprimir el ticket de prueba. Verifique que la impresora esté encendida.',
          ),
          backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    await PrintManager.saveLocalPaperSize(_selectedSize);
    await PrintManager.saveIsDirectPrintEnabled(_isDirectPrint);
    await PrintManager.saveSavedPrinter(_selectedPrinter);
    await PrintManager.saveAutoCutEnabled(_autoCut);
    await PrintManager.saveInvertColorEnabled(_invertColor);
    await PrintManager.saveDitheringEnabled(_dithering);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.print_rounded),
          SizedBox(width: 8),
          Text('Configuración de Impresora Local'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección: Tamaño de papel
              Text(
                'Tamaño de Papel Térmico',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PaperSize>(
                segments: const [
                  ButtonSegment<PaperSize>(
                    value: PaperSize.mm80,
                    label: Text('80 mm (Estándar)'),
                    icon: Icon(Icons.receipt_long_rounded),
                  ),
                  ButtonSegment<PaperSize>(
                    value: PaperSize.mm58,
                    label: Text('58 mm (Compacto)'),
                    icon: Icon(Icons.receipt_rounded),
                  ),
                ],
                selected: {_selectedSize},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedSize = selection.first;
                  });
                },
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Sección: Modo de Impresión
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Impresión Térmica Directa (1 Clic)'),
                subtitle: const Text(
                  'Imprime de inmediato por Bluetooth/USB sin abrir el cuadro de diálogo de Android ni usar apps externas.',
                ),
                value: _isDirectPrint,
                onChanged: (value) {
                  setState(() {
                    _isDirectPrint = value;
                  });
                },
              ),

              if (_isDirectPrint) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Corte Automático de Papel'),
                  subtitle: const Text('Envía el comando de corte al terminar de imprimir.'),
                  value: _autoCut,
                  onChanged: (value) {
                    setState(() {
                      _autoCut = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tramado de Alta Fidelidad (Halftone)'),
                  subtitle: const Text(
                    'Simula sombras y tonos de gris mediante micro-puntos térmicos para que logos e imágenes se vean con máxima definición.',
                  ),
                  value: _dithering,
                  onChanged: (value) {
                    setState(() {
                      _dithering = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Invertir Colores (Blanco y Negro)'),
                  subtitle: const Text(
                    'Activar únicamente si su modelo de impresora térmica imprime en negativo o con colores invertidos.',
                  ),
                  value: _invertColor,
                  onChanged: (value) {
                    setState(() {
                      _invertColor = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Tarjeta de Impresora Seleccionada
                Card(
                  elevation: 0,
                  color: _selectedPrinter != null
                      ? theme.colorScheme.primaryContainer.withAlpha(80)
                      : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selectedPrinter != null
                          ? theme.colorScheme.primary.withAlpha(120)
                          : theme.dividerColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedPrinter != null ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              color: _selectedPrinter != null ? Colors.green : theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedPrinter != null
                                    ? 'Impresora Vinculada: ${_selectedPrinter!.name}'
                                    : 'Ninguna impresora vinculada',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (_selectedPrinter != null)
                              IconButton(
                                tooltip: 'Desvincular',
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedPrinter = null;
                                  });
                                },
                              ),
                          ],
                        ),
                        if (_selectedPrinter != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Dirección / MAC: ${_selectedPrinter!.address ?? "N/A"}  •  Tipo: ${_selectedPrinter!.connectionTypeString}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: _isTesting ? null : _testPrint,
                              icon: _isTesting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.bolt_rounded, size: 18),
                              label: const Text('Probar Impresión'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de escaneo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dispositivos Disponibles',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _toggleScan,
                      icon: _isScanning
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search_rounded, size: 18),
                      label: Text(_isScanning ? 'Detener' : 'Buscar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isScanning && _discoveredPrinters.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Buscando impresoras Bluetooth y USB...'),
                        ],
                      ),
                    ),
                  )
                else if (_discoveredPrinters.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Presione "Buscar" para detectar impresoras Bluetooth o USB cercanas.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _discoveredPrinters.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final printer = _discoveredPrinters[index];
                        final isSelected = _selectedPrinter?.address == printer.address;

                        return ListTile(
                          dense: true,
                          leading: Icon(
                            printer.connectionType == ConnectionType.USB
                                ? Icons.usb_rounded
                                : Icons.bluetooth_rounded,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                          title: Text(
                            printer.name ?? 'Impresora sin nombre',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(printer.address ?? 'Sin dirección'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedPrinter = printer;
                                    });
                                  },
                                  child: const Text('Vincular'),
                                ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
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
