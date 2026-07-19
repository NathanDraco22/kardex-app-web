part of 'create_product_dialog.dart';

class ExtraUnitsSection extends StatefulWidget {
  const ExtraUnitsSection({
    super.key,
    required this.creationMap,
    this.currentProduct,
  });

  final Map creationMap;
  final ProductInDb? currentProduct;

  @override
  State<ExtraUnitsSection> createState() => _ExtraUnitsSectionState();
}

class _ExtraUnitsSectionState extends State<ExtraUnitsSection> {
  final List<ExtraUnit> _extraUnits = [];
  int _defaultUnitIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentProduct != null) {
      _extraUnits.addAll(widget.currentProduct!.extraUnits);
      _defaultUnitIndex = widget.currentProduct!.defaultUnitIndex;
    }
    _syncToMap();
  }

  void _syncToMap() {
    widget.creationMap['extraUnits'] = _extraUnits.map((e) => e.toJson()).toList();
    if (_defaultUnitIndex > _extraUnits.length) {
      _defaultUnitIndex = 0;
    }
    widget.creationMap['defaultUnitIndex'] = _defaultUnitIndex;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  baseUnitName: baseUnitName,
                );

                if (result != null) {
                  setState(() {
                    _extraUnits.clear();
                    _extraUnits.addAll(result.extraUnits);
                    _defaultUnitIndex = result.defaultUnitIndex;
                    _syncToMap();
                  });
                }
              },
              icon: const Icon(Icons.scale),
              label: Text("Unidades de Medida Extra (${_extraUnits.length})"),
            ),
          ],
        ),
      ],
    );
  }
}
