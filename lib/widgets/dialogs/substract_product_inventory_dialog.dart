import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/inventory_unit_tool.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

Future<int?> showSubstractProductInventoryDialog(
  BuildContext context, {
  required ProductInDbInBranch product,
  required bool allowNegativeStock,
}) async {
  return await showDialog<int>(
    context: context,
    builder: (context) {
      return _SubstractInventoryDialog(
        product: product,
        allowNegativeStock: allowNegativeStock,
      );
    },
  );
}

class _SubstractInventoryDialog extends StatefulWidget {
  const _SubstractInventoryDialog({
    required this.product,
    required this.allowNegativeStock,
  });

  final ProductInDbInBranch product;
  final bool allowNegativeStock;

  @override
  State<_SubstractInventoryDialog> createState() => _SubstractInventoryDialogState();
}

class _SubstractInventoryDialogState extends State<_SubstractInventoryDialog> {
  final _formKey = GlobalKey<FormState>();

  late final List<InventoryUnitOption> _unitOptions;
  late InventoryUnitOption _selectedUnit;
  late final TextEditingController _quantityController;

  double _displayQuantity = 0;
  String? _unitChangeMessage;

  @override
  void initState() {
    super.initState();
    _unitOptions = InventoryUnitTool.buildOptions(
      baseUnitName: widget.product.unitName,
      extraUnits: widget.product.extraUnits,
    );
    _selectedUnit = InventoryUnitTool.resolveDefault(
      options: _unitOptions,
      defaultUnitIndex: widget.product.defaultUnitIndex,
    );
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _selectUnit(InventoryUnitOption newUnit) {
    if (newUnit.index == _selectedUnit.index) return;

    final oldUnit = _selectedUnit;
    final convertedQuantity = InventoryUnitTool.convertDisplayQuantity(
      displayQuantity: _displayQuantity,
      oldFactor: oldUnit.factor,
      newFactor: newUnit.factor,
      newUnitIndex: newUnit.index,
      defaultUnitIndex: widget.product.defaultUnitIndex,
    );

    setState(() {
      _selectedUnit = newUnit;
      _displayQuantity = convertedQuantity ?? 0;
      _quantityController.text = convertedQuantity == null
          ? ''
          : InventoryUnitTool.formatQuantity(convertedQuantity);
      _unitChangeMessage = convertedQuantity == null
          ? "La cantidad anterior no equivale a una cantidad exacta en ${newUnit.name}."
          : null;
    });
  }

  void _onQuantityChanged(double value) {
    _displayQuantity = value;
    if (_unitChangeMessage != null) {
      setState(() => _unitChangeMessage = null);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final baseQuantity = InventoryUnitTool.toBaseQuantity(_displayQuantity, _selectedUnit.factor);
    if (baseQuantity <= 0) {
      DialogManager.showErrorDialog(context, "La cantidad debe ser mayor a 0");
      return;
    }

    if (!widget.allowNegativeStock && baseQuantity > widget.product.account.currentStock) {
      DialogManager.showErrorDialog(
        context,
        "No hay suficiente existencia para restar esa cantidad",
      );
      return;
    }

    Navigator.pop(context, baseQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final currentStock = widget.product.account.currentStock;
    final displayStock = InventoryUnitTool.formatBaseStock(currentStock, _selectedUnit.factor);
    final availableStockText = _selectedUnit.factor > 1
        ? "Disponible: $displayStock ${_selectedUnit.name} ($currentStock ${widget.product.unitName})"
        : "Disponible: $currentStock ${widget.product.unitName}";
    final allowsDecimals = InventoryUnitTool.allowsDecimals(
      option: _selectedUnit,
      defaultUnitIndex: widget.product.defaultUnitIndex,
    );

    return AlertDialog(
      title: const Text("Restar del Inventario"),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<InventoryUnitOption>(
                  key: ValueKey(_selectedUnit.index),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Unidad',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedUnit,
                  items: _unitOptions.map((unit) {
                    return DropdownMenuItem<InventoryUnitOption>(
                      value: unit,
                      child: Text(
                        unit.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectUnit(value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  availableStockText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                QuantityField(
                  controller: _quantityController,
                  conversionFactor: _selectedUnit.factor,
                  allowDecimals: allowsDecimals,
                  step: UnitConversionTool.minimumStep(_selectedUnit.factor),
                  max: widget.allowNegativeStock ? null : currentStock / _selectedUnit.factor,
                  showTitle: true,
                  title: "Cantidad a restar (${_selectedUnit.name})",
                  titleTextAlign: TextAlign.start,
                  autofocus: true,
                  equivalenceUnitName: widget.product.unitName,
                  equivalenceFactor: 1,
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.isEmpty) return "Campo requerido";
                    final parsed = double.tryParse(text.replaceAll(',', '.')) ?? 0;
                    if (parsed <= 0) return "La cantidad debe ser mayor a 0";
                    if (!widget.allowNegativeStock) {
                      final baseQuantity = InventoryUnitTool.toBaseQuantity(parsed, _selectedUnit.factor);
                      if (baseQuantity > currentStock) {
                        return "No hay suficiente existencia";
                      }
                    }
                    return null;
                  },
                  onChanged: _onQuantityChanged,
                ),
                if (_unitChangeMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _unitChangeMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Restar"),
        ),
      ],
    );
  }
}
