import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class DiscountTile extends StatelessWidget {
  const DiscountTile({
    super.key,
    required this.name,
    required this.percentValue,
    required this.amountValue,
    required this.totalValue,
    required this.onEditPressed,
    required this.onDeletedPressed,
  });

  final String name;
  final int percentValue;
  final int amountValue;
  final int totalValue;

  final void Function() onEditPressed;
  final void Function() onDeletedPressed;

  @override
  Widget build(BuildContext context) {
    final convertedAmount = NumberFormatter.convertToMoneyLike(amountValue);
    final convertedTotal = NumberFormatter.convertToMoneyLike(totalValue);
    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$percentValue%"),
                      Text(convertedAmount),
                      Text(convertedTotal),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: "edit",
                          child: Text("Editar"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Eliminar"),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == "edit") {
                        onEditPressed();
                      } else if (value == "delete") {
                        onDeletedPressed();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
