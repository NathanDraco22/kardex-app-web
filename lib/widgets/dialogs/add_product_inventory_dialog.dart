import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';
import 'package:kardex_app_front/src/tools/inventory_unit_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

Future<Map<String, int?>?> showAddProductInventoryDialog(
  BuildContext context, {
  required ProductInDbInBranch product,
}) async {
  return await showDialog<Map<String, int?>>(
    context: context,
    builder: (context) {
      return _AddInventoryDialog(product: product);
    },
  );
}

class _AddInventoryDialog extends StatefulWidget {
  const _AddInventoryDialog({required this.product});

  final ProductInDbInBranch product;

  @override
  State<_AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends State<_AddInventoryDialog> {
  final _formKey = GlobalKey<FormState>();

  late final List<InventoryUnitOption> _unitOptions;
  late InventoryUnitOption _selectedUnit;
  late final TextEditingController _quantityController;
  late final TextEditingController _costController;

  double _displayQuantity = 0;
  int _displayCostCents = 0;
  String _expirationDateText = "";
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
    _displayCostCents = InventoryUnitTool.toDisplayCost(
      widget.product.account.averageCost,
      _selectedUnit.factor,
    );
    _quantityController = TextEditingController();
    _costController = TextEditingController(
      text: InventoryUnitTool.formatMoney(_displayCostCents),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
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
    final convertedCost = InventoryUnitTool.convertDisplayCost(
      displayCostCents: _displayCostCents,
      oldFactor: oldUnit.factor,
      newFactor: newUnit.factor,
    );

    setState(() {
      _selectedUnit = newUnit;
      _displayQuantity = convertedQuantity ?? 0;
      _quantityController.text = convertedQuantity == null
          ? ''
          : InventoryUnitTool.formatQuantity(convertedQuantity);
      _displayCostCents = convertedCost;
      _costController.text = InventoryUnitTool.formatMoney(_displayCostCents);
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

  void _onCostChanged(String value) {
    final formattedValue = value.replaceAll(',', '');
    setState(() {
      _displayCostCents = ((double.tryParse(formattedValue) ?? 0) * 100).round();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final baseQuantity = InventoryUnitTool.toBaseQuantity(_displayQuantity, _selectedUnit.factor);
    if (baseQuantity <= 0) {
      await DialogManager.showErrorDialog(context, "La cantidad debe ser mayor a 0");
      return;
    }

    final baseCost = InventoryUnitTool.toBaseCost(_displayCostCents, _selectedUnit.factor);
    if (baseCost <= 0) {
      await DialogManager.showErrorDialog(
        context,
        "El costo por ${_selectedUnit.name} es demasiado bajo para la unidad base",
      );
      return;
    }

    int? expirationDate;
    if (_expirationDateText.isNotEmpty) {
      if (_expirationDateText.length < 5) {
        await DialogManager.showErrorDialog(context, "Formato de fecha de vencimiento inválido (MM/AA)");
        return;
      }
      try {
        final parsedDate = DateTimeTool.fromMMYY(_expirationDateText);
        expirationDate = parsedDate.millisecondsSinceEpoch;
      } catch (_) {
        await DialogManager.showErrorDialog(context, "Formato de fecha de vencimiento inválido (MM/AA)");
        return;
      }
    }

    if (!mounted) return;
    Navigator.pop(context, {
      "currentStock": baseQuantity,
      "averageCost": baseCost,
      "expirationDate": expirationDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseCostCents = InventoryUnitTool.toBaseCost(_displayCostCents, _selectedUnit.factor);
    final allowsDecimals = InventoryUnitTool.allowsDecimals(
      option: _selectedUnit,
      defaultUnitIndex: widget.product.defaultUnitIndex,
    );

    return AlertDialog(
      title: const Text("Agregar al Inventario"),
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
                const SizedBox(height: 12),
                QuantityField(
                  controller: _quantityController,
                  conversionFactor: _selectedUnit.factor,
                  allowDecimals: allowsDecimals,
                  step: UnitConversionTool.minimumStep(_selectedUnit.factor),
                  showTitle: true,
                  title: "Cantidad a agregar (${_selectedUnit.name})",
                  titleTextAlign: TextAlign.start,
                  autofocus: true,
                  equivalenceUnitName: widget.product.unitName,
                  equivalenceFactor: 1,
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.isEmpty) return "Campo requerido";
                    final parsed = double.tryParse(text.replaceAll(',', '.')) ?? 0;
                    if (parsed <= 0) return "La cantidad debe ser mayor a 0";
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
                const SizedBox(height: 12),
                TitleTextField(
                  title: "Costo Unitario (${NumberFormatter.currencySymbol} / ${_selectedUnit.name})",
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DoubleThousandsFormatter()],
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.isEmpty) return "Campo requerido";
                    final parsed = double.tryParse(text.replaceAll(',', '')) ?? 0;
                    if (parsed <= 0) return "El costo debe ser mayor a 0";
                    return null;
                  },
                  onChanged: _onCostChanged,
                ),
                const SizedBox(height: 4),
                Text(
                  "Costo base: ${NumberFormatter.convertToMoneyLike(baseCostCents)} / ${widget.product.unitName}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
                ExpirationDateGate(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TitleTextField(
                      title: "Fecha de Vencimiento (MES/AÑO)",
                      decoration: const InputDecoration(hintText: "MM/AA"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [MonthYearInputFormatter()],
                      onChanged: (val) {
                        _expirationDateText = val.trim();
                      },
                    ),
                  ),
                ),
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
          child: const Text("Agregar"),
        ),
      ],
    );
  }
}
