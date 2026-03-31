import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<Map<String, int>?> showAddProductInventoryDialog(
  BuildContext context, {
  required int currentAverageCost,
}) async {
  return await showDialog<Map<String, int>>(
    context: context,
    builder: (context) {
      return _AddInventoryDialog(
        currentAverageCost: currentAverageCost,
      );
    },
  );
}

class _AddInventoryDialog extends StatefulWidget {
  final int currentAverageCost;

  const _AddInventoryDialog({
    required this.currentAverageCost,
  });

  @override
  State<_AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends State<_AddInventoryDialog> {
  int stockToAdd = 0;
  int averageCost = 0;

  @override
  void initState() {
    super.initState();
    averageCost = widget.currentAverageCost;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar al Inventario"),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleTextField(
              title: "Cantidad a agregar",
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (val) {
                stockToAdd = int.tryParse(val) ?? 0;
              },
            ),
            const SizedBox(height: 12),
            TitleTextField(
              title: "Costo Unitario (C\$ )",
              initialValue: NumberFormatter.convertFromCentsToDouble(averageCost).toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [DoubleThousandsFormatter()],
              onChanged: (val) {
                final formattedValue = val.replaceAll(",", "");
                final cents = ((double.tryParse(formattedValue) ?? 0) * 100).round();
                averageCost = cents;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (stockToAdd <= 0) {
              DialogManager.showErrorDialog(context, "La cantidad debe ser mayor a 0");
              return;
            }
            if (averageCost <= 0) {
              DialogManager.showErrorDialog(context, "El costo debe ser mayor a 0");
              return;
            }
            Navigator.pop(context, {
              "currentStock": stockToAdd,
              "averageCost": averageCost,
            });
          },
          child: const Text("Agregar"),
        ),
      ],
    );
  }
}
