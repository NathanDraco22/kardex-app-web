import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

import '../title_label.dart';

/// Un costo expresado en la unidad base del producto.
class UnitCostItem {
  const UnitCostItem({
    required this.label,
    required this.baseCostInCents,
  });

  final String label;
  final int baseCostInCents;
}

enum UnitCostComparisonLayout { table, vertical }

/// Muestra los costos en la unidad base y en la unidad comercial seleccionada.
///
/// La unidad base se presenta primero y con mayor peso visual. La unidad
/// seleccionada se muestra como equivalencia, no como el único valor.
class UnitCostComparison extends StatelessWidget {
  const UnitCostComparison({
    super.key,
    required this.items,
    required this.baseUnitName,
    required this.selectedUnitName,
    required this.selectedUnitFactor,
    this.layout = UnitCostComparisonLayout.table,
  });

  final List<UnitCostItem> items;
  final String baseUnitName;
  final String selectedUnitName;
  final int selectedUnitFactor;
  final UnitCostComparisonLayout layout;

  int get _factor => selectedUnitFactor <= 1 ? 1 : selectedUnitFactor;

  String get _selectedName {
    final name = selectedUnitName.trim();
    return name.isEmpty ? baseUnitName : name;
  }

  bool get _hasConversion => _factor > 1 && _selectedName != baseUnitName;

  @override
  Widget build(BuildContext context) {
    if (!_hasConversion) {
      return layout == UnitCostComparisonLayout.vertical ? _buildVertical() : _buildSimpleRow();
    }

    return layout == UnitCostComparisonLayout.vertical ? _buildVertical() : _buildTable();
  }

  Widget _buildSimpleRow() {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: TitleLabel(
              title: items[i].label,
              bigTitle: NumberFormatter.convertToMoneyLike(
                items[i].baseCostInCents,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTable() {
    const labelStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
    );
    const baseValueStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final selectedValueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.blue.shade700,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox.shrink()),
              for (final item in items) ...[
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Text(
                    item.label,
                    style: labelStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Base',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          baseUnitName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                for (final item in items) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        NumberFormatter.convertToMoneyLike(
                          item.baseCostInCents,
                        ),
                        style: baseValueStyle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, top: 5),
                  child: Text(
                    _selectedName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              for (final item in items) ...[
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        NumberFormatter.convertToMoneyLike(
                          item.baseCostInCents * _factor,
                        ),
                        style: selectedValueStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVertical() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 12),
          _buildVerticalItem(items[i]),
        ],
      ],
    );
  }

  Widget _buildVerticalItem(UnitCostItem item) {
    final baseValue = NumberFormatter.convertToMoneyLike(item.baseCostInCents);
    final selectedValue = NumberFormatter.convertToMoneyLike(
      item.baseCostInCents * _factor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Base · $baseUnitName',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  baseValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_hasConversion) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  _selectedName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    selectedValue,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
