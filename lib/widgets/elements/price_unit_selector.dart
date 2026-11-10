import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

/// Selector de la unidad extra para la que se muestran los precios.
///
/// La unidad base siempre es la primera columna. Este selector solo cambia
/// la unidad de referencia para calcular y editar precios equivalentes.
class PriceUnitSelector extends StatelessWidget {
  const PriceUnitSelector({
    super.key,
    required this.baseUnitName,
    required this.extraUnits,
    required this.selectedUnit,
    required this.onChanged,
  });

  final String baseUnitName;
  final List<ExtraUnit> extraUnits;
  final ExtraUnit? selectedUnit;
  final ValueChanged<ExtraUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    if (extraUnits.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveSelected = extraUnits.firstWhere(
      (unit) =>
          selectedUnit != null &&
          unit.name == selectedUnit!.name &&
          unit.conversionFactor == selectedUnit!.conversionFactor,
      orElse: () => extraUnits.first,
    );

    final baseInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Precio Base para:",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          baseUnitName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );

    final unitDropdown = DropdownButtonFormField<ExtraUnit>(
      key: ValueKey(effectiveSelected),
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Calcular para la unidad:',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      initialValue: effectiveSelected,
      items: extraUnits.map((extra) {
        return DropdownMenuItem<ExtraUnit>(
          value: extra,
          child: Text(
            extra.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              baseInfo,
              const SizedBox(height: 12),
              unitDropdown,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: baseInfo),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: unitDropdown),
          ],
        );
      },
    );
  }
}
