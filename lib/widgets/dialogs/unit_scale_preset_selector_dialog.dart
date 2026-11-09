import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/feature_flags.dart';
import 'package:kardex_business/kardex_business.dart';

Future<BaseUnitScale?> showUnitScalePresetSelectorDialog(BuildContext context) async {
  if (!FeatureFlags.showUnitScales) return null;

  return await showDialog<BaseUnitScale?>(
    context: context,
    builder: (context) => const UnitScalePresetSelectorDialog(),
  );
}

class UnitScalePresetSelectorDialog extends StatefulWidget {
  const UnitScalePresetSelectorDialog({super.key});

  @override
  State<UnitScalePresetSelectorDialog> createState() => _UnitScalePresetSelectorDialogState();
}

class _UnitScalePresetSelectorDialogState extends State<UnitScalePresetSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<BaseUnitScale> _customScales = [];
  bool _isLoading = true;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadCustomScales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomScales() async {
    try {
      final repo = context.read<UnitScalesRepository>();
      final scales = await repo.getAllUnitScales();
      if (mounted) {
        setState(() {
          _customScales = scales;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<BaseUnitScale> get _filteredStandards {
    if (_filter.isEmpty) return UnitScalePresets.standardPresets;
    final term = _filter.toLowerCase();
    return UnitScalePresets.standardPresets.where((p) {
      return p.name.toLowerCase().contains(term) ||
          p.baseUnit.toLowerCase().contains(term) ||
          p.scaleType.label.toLowerCase().contains(term) ||
          p.units.any((u) => u.name.toLowerCase().contains(term));
    }).toList();
  }

  List<BaseUnitScale> get _filteredCustoms {
    if (_filter.isEmpty) return _customScales;
    final term = _filter.toLowerCase();
    return _customScales.where((p) {
      return p.name.toLowerCase().contains(term) ||
          p.baseUnit.toLowerCase().contains(term) ||
          p.scaleType.label.toLowerCase().contains(term) ||
          p.units.any((u) => u.name.toLowerCase().contains(term));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final standards = _filteredStandards;
    final customs = _filteredCustoms;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cargar Preset de Unidades',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Selecciona una escala para autocompletar unidades y conversiones',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buscador
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar escala (ej. Libra, Caja x30, Docena)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _filter.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _filter = '');
                          },
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setState(() => _filter = val.trim()),
              ),
              const SizedBox(height: 12),

              // Lista de Presets
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (standards.isEmpty && customs.isEmpty)
                    ? Center(
                        child: Text(
                          'No se encontraron escalas para "$_filter"',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView(
                        children: [
                          if (standards.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Presets Rápidos del Sistema',
                              count: standards.length,
                              icon: Icons.star_outline,
                            ),
                            ...standards.map(
                              (preset) => _PresetCard(
                                preset: preset,
                                isCustom: false,
                                onSelect: () => Navigator.pop(context, preset),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (customs.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Escalas Disponibles',
                              count: customs.length,
                              icon: Icons.bookmark_outline,
                            ),
                            ...customs.map(
                              (preset) => _PresetCard(
                                preset: preset,
                                isCustom: true,
                                onSelect: () => Navigator.pop(context, preset),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.isCustom,
    required this.onSelect,
  });

  final BaseUnitScale preset;
  final bool isCustom;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelect,
        hoverColor: theme.colorScheme.primary.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                preset.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.shade200, width: 0.8),
                    ),
                    child: Text(
                      preset.scaleType.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCustom ? Colors.purple.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCustom ? Colors.purple.shade200 : Colors.blue.shade200,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      isCustom ? 'Personalizado' : 'Sugerido',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCustom ? Colors.purple.shade800 : Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Unidad Base: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    preset.baseUnit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: preset.units.map((u) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300, width: 0.6),
                    ),
                    child: Text(
                      '${u.name} = ${u.conversionFactor} ${preset.baseUnit}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
