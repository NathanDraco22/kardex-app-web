import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<int?> showSubstractProductInventoryDialog(BuildContext context) async {
  return await showDialog<int>(
    context: context,
    builder: (context) {
      return const _SubstractInventoryDialog();
    },
  );
}

class _SubstractInventoryDialog extends StatefulWidget {
  const _SubstractInventoryDialog();

  @override
  State<_SubstractInventoryDialog> createState() => _SubstractInventoryDialogState();
}

class _SubstractInventoryDialogState extends State<_SubstractInventoryDialog> {
  int stockToSubstract = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Restar del Inventario"),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleTextField(
              title: "Cantidad a restar",
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (val) {
                stockToSubstract = int.tryParse(val) ?? 0;
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
            if (stockToSubstract <= 0) {
              DialogManager.showErrorDialog(context, "La cantidad debe ser mayor a 0");
              return;
            }
            Navigator.pop(context, stockToSubstract);
          },
          child: const Text("Restar"),
        ),
      ],
    );
  }
}
