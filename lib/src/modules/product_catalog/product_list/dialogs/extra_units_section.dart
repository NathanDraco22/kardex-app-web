part of 'create_product_dialog.dart';

class ExtraUnitsSection extends StatefulWidget {
  const ExtraUnitsSection({
    super.key,
    required this.creationMap,
    this.currentProduct,
    this.onPresetApplied,
  });

  final Map creationMap;
  final ProductInDb? currentProduct;
  final ValueChanged<BaseUnitScale>? onPresetApplied;

  @override
  State<ExtraUnitsSection> createState() => _ExtraUnitsSectionState();
}

class _ExtraUnitsSectionState extends State<ExtraUnitsSection> {
  final List<ExtraUnit> _extraUnits = [];
  int _defaultUnitIndex = 0;
  int _wholesaleUnitIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentProduct != null) {
      _extraUnits.addAll(widget.currentProduct!.extraUnits);
      _defaultUnitIndex = widget.currentProduct!.defaultUnitIndex;
      _wholesaleUnitIndex = widget.currentProduct!.wholesaleUnitIndex;
    }
    _syncToMap();
  }

  void _syncToMap() {
    widget.creationMap['extraUnits'] = _extraUnits.map((e) => e.toJson()).toList();
    if (_defaultUnitIndex > _extraUnits.length) {
      _defaultUnitIndex = 0;
    }
    widget.creationMap['defaultUnitIndex'] = _defaultUnitIndex;

    if (_wholesaleUnitIndex > _extraUnits.length) {
      _wholesaleUnitIndex = 0;
    }
    widget.creationMap['wholesaleUnitIndex'] = _wholesaleUnitIndex;
  }

  Future<void> _applyPreset() async {
    final preset = await showUnitScalePresetSelectorDialog(context);
    if (preset == null) return;

    setState(() {
      _extraUnits.clear();
      _extraUnits.addAll(preset.units);
      _defaultUnitIndex = preset.defaultUnitIndex;
      _wholesaleUnitIndex = preset.wholesaleUnitIndex;
      _syncToMap();
    });

    widget.creationMap['unitName'] = preset.baseUnit;
    widget.onPresetApplied?.call(preset);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preset "${preset.name}" aplicado correctamente'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUnitName = widget.creationMap['unitName'] as String? ??
        widget.currentProduct?.unitName ??
        'Unidad Base';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                final result = await showProductExtraUnitsEditor(
                  context,
                  initialExtraUnits: _extraUnits,
                  initialDefaultUnitIndex: _defaultUnitIndex,
                  initialWholesaleUnitIndex: _wholesaleUnitIndex,
                  baseUnitName: baseUnitName,
                );

                if (result != null) {
                  setState(() {
                    _extraUnits.clear();
                    _extraUnits.addAll(result.extraUnits);
                    _defaultUnitIndex = result.defaultUnitIndex;
                    _wholesaleUnitIndex = result.wholesaleUnitIndex;
                    _syncToMap();
                  });
                }
              },
              icon: const Icon(Icons.scale),
              label: Text("Unidades Extra (${_extraUnits.length})"),
            ),
            FilledButton.tonalIcon(
              onPressed: _applyPreset,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text("Usar Preset"),
            ),
          ],
        ),
      ],
    );
  }
}
