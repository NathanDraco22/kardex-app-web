import 'package:material_ui/material_ui.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

/// Muestra el diálogo para configurar la etiqueta del identificador tributario
/// según el país (ej. RUC, RTN, NIT, RFC o personalizada).
Future<bool?> showTaxIdLabelSettingsDialog(
  BuildContext context, {
  required String currentLabel,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _TaxIdLabelSettingsDialog(
      initialLabel: currentLabel,
    ),
  );
}

class _TaxIdLabelSettingsDialog extends StatefulWidget {
  const _TaxIdLabelSettingsDialog({
    required this.initialLabel,
  });

  final String initialLabel;

  @override
  State<_TaxIdLabelSettingsDialog> createState() =>
      _TaxIdLabelSettingsDialogState();
}

class _TaxIdLabelSettingsDialogState extends State<_TaxIdLabelSettingsDialog> {
  static const String _customKey = '__custom__';

  late String _selectedKey;
  late final TextEditingController _customController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final normalized = AppTaxIdLabel.normalize(widget.initialLabel);
    final preset = AppTaxIdLabel.tryFromLabel(normalized);
    if (preset != null) {
      _selectedKey = preset.label;
      _customController = TextEditingController();
    } else {
      _selectedKey = _customKey;
      _customController = TextEditingController(text: normalized);
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _isCustom => _selectedKey == _customKey;

  String get _effectiveLabel {
    if (_isCustom) {
      return _customController.text.trim();
    }
    return _selectedKey;
  }

  bool get _canSave => !_isSaving && _effectiveLabel.isNotEmpty;

  Future<void> _save() async {
    final label = _effectiveLabel;
    if (label.isEmpty) {
      setState(() => _error = 'Ingresa una etiqueta válida (ej. RUC, RTN, NIT).');
      return;
    }
    if (label.length > 32) {
      setState(() => _error = 'La etiqueta no debe superar 32 caracteres.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final success = await getIt<AppSettingsCubit>().updateSettings(
      UpdateAppSetting(taxIdLabel: label),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSaving = false;
        _error = 'No se pudo guardar la etiqueta tributaria.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewLabel = _effectiveLabel.isEmpty ? 'RUC' : _effectiveLabel;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: Colors.teal.shade700,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identificación tributaria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Elige cómo se denomina en tu país',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedKey,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'País / Etiqueta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  ...AppTaxIdLabel.values.map(
                    (preset) => DropdownMenuItem<String>(
                      value: preset.label,
                      child: Text(
                        '${preset.label}  ·  ${preset.countries}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    value: _customKey,
                    child: Text('Otro (personalizado)...'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedKey = value;
                          _error = null;
                        });
                      },
              ),
              if (_isCustom) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customController,
                  enabled: !_isSaving,
                  maxLength: 32,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(
                    labelText: 'Nombre personalizado',
                    hintText: 'Ej: RUC, RTN, NIT, Tax ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista previa en facturas y tickets',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$previewLabel: J0310000123456',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _canSave ? _save : null,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    );
  }
}
