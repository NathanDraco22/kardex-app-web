import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class UnitPickerResult {
  final int unitIndex;
  final int conversionFactor;
  final String unitName;

  const UnitPickerResult({
    required this.unitIndex,
    required this.conversionFactor,
    required this.unitName,
  });
}

class _UnitOption {
  final int index;
  final String name;
  final int factor;
  const _UnitOption({
    required this.index,
    required this.name,
    required this.factor,
  });
}

Future<UnitPickerResult?> showInventoryUnitPicker(
  BuildContext context,
  ProductInDb product,
) async {
  final account = product is ProductInDbInBranch ? product.account : null;
  final hasExtras = product.extraUnits.isNotEmpty;

  // Si no hay unidades extra configuradas, retornamos la unidad base directamente para evitar fricción
  if (!hasExtras) {
    return UnitPickerResult(
      unitIndex: 0,
      conversionFactor: 1,
      unitName: product.unitName,
    );
  }

  final unitOptions = <_UnitOption>[
    _UnitOption(index: 0, name: product.unitName, factor: 1),
    for (var i = 0; i < product.extraUnits.length; i++)
      _UnitOption(
        index: i + 1,
        name: product.extraUnits[i].name,
        factor: product.extraUnits[i].conversionFactor,
      ),
  ];

  return await showDialog<UnitPickerResult?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _InventoryUnitPickerDialog(
      product: product,
      unitOptions: unitOptions,
      account: account,
    ),
  );
}

class _InventoryUnitPickerDialog extends StatefulWidget {
  const _InventoryUnitPickerDialog({
    required this.product,
    required this.unitOptions,
    this.account,
  });

  final ProductInDb product;
  final List<_UnitOption> unitOptions;
  final ProductAccountInDb? account;

  @override
  State<_InventoryUnitPickerDialog> createState() => _InventoryUnitPickerDialogState();
}

class _InventoryUnitPickerDialogState extends State<_InventoryUnitPickerDialog> {
  late _UnitOption selectedOption;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final defaultIndex = widget.product.defaultUnitIndex;
    int initialFocusIndex = 0;
    if (defaultIndex >= 0 && defaultIndex < widget.unitOptions.length) {
      selectedOption = widget.unitOptions[defaultIndex];
      initialFocusIndex = defaultIndex;
    } else {
      selectedOption = widget.unitOptions.first;
    }

    _focusNodes = List.generate(
      widget.unitOptions.length,
      (index) => FocusNode(),
    );

    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            selectedOption = widget.unitOptions[i];
          });
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.unitOptions.length > 1) {
        _focusNodes[initialFocusIndex].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;

    return AlertDialog(
      title: const Text(
        "Seleccionar Unidad",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (widget.product.brandName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                widget.product.brandName,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            if (widget.unitOptions.length > 1) ...[
              const Text(
                "Unidades Disponibles:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Column(
                children: List.generate(widget.unitOptions.length, (index) {
                  final opt = widget.unitOptions[index];
                  final isFocused = _focusNodes[index].hasFocus;
                  final isSelected = selectedOption == opt;
                  final label = opt.factor == 1 ? opt.name : '${opt.name} (x${opt.factor})';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isFocused
                            ? Theme.of(context).colorScheme.primary.withAlpha(20)
                            : isSelected
                            ? Theme.of(context).colorScheme.primary.withAlpha(8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFocused
                              ? Theme.of(context).colorScheme.primary
                              : isSelected
                              ? Theme.of(context).colorScheme.primary.withAlpha(128)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: ListTile(
                        focusNode: _focusNodes[index],
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isFocused || isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isFocused || isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                          ),
                        ),
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isFocused || isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            selectedOption = opt;
                          });
                          Navigator.pop(
                            context,
                            UnitPickerResult(
                              unitIndex: opt.index,
                              conversionFactor: opt.factor,
                              unitName: opt.name,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
            if (account != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCostRow(
                      "Costo Promedio:",
                      account.averageCost * selectedOption.factor,
                    ),
                    const SizedBox(height: 6),
                    _buildCostRow(
                      "Última Compra:",
                      account.lastCost * selectedOption.factor,
                    ),
                    const SizedBox(height: 6),
                    _buildCostRow(
                      "Costo Máximo:",
                      account.maximumCost * selectedOption.factor,
                    ),
                  ],
                ),
              ),
              if (selectedOption.factor > 1) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Costo promedio base (${widget.product.unitName}): ${NumberFormatter.convertToMoneyLike(account.averageCost)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          autofocus: widget.unitOptions.length == 1,
          onPressed: () {
            Navigator.pop(
              context,
              UnitPickerResult(
                unitIndex: selectedOption.index,
                conversionFactor: selectedOption.factor,
                unitName: selectedOption.name,
              ),
            );
          },
          child: const Text("Agregar"),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, int cents) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          NumberFormatter.convertToMoneyLike(cents),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    );
  }
}
