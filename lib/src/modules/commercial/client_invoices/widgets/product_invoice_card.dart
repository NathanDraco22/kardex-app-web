import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/title_label.dart';

class ProductInvoiceCard extends StatelessWidget {
  const ProductInvoiceCard({
    super.key,
    required this.tileColor,
    required this.item,
    required this.percentDiscount,
    this.onEdit,
    this.onRemove,
    this.onChange,
  });

  final Color tileColor;
  final int percentDiscount;
  final CommercialProductResult item;

  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final priceFormatted = NumberFormatter.convertFromCentsToDouble(item.newPrice);
    final discountFormatted = NumberFormatter.convertFromCentsToDouble(item.totalDiscount);
    final totalFormatted = NumberFormatter.convertToMoneyLike(item.total);

    Offset? offset;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: (details) {
          offset = details.globalPosition;
        },
        onLongPress: () async {
          if (offset == null) return;
          final res = await _showContextMenu(context, offset!);
          offset = null;
          if (res == null) return;
          switch (res) {
            case _MenuOptions.edit:
              onEdit?.call();
            case _MenuOptions.change:
              onChange?.call();
            case _MenuOptions.delete:
              onRemove?.call();
          }
        },
        child: Ink(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: tileColor,
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 12),
                  Text(item.product.displayCode),
                ],
              ),
              Row(
                spacing: 12,
                children: [
                  Text(item.product.brandName),
                  Text(item.product.unitName),
                ],
              ),
              const Divider(
                height: 2,
              ),

              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Unidades: "),
                  Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // if (item.bonQuantity > 0)
                  //   Text(
                  //     item.bonQuantity.toString(),
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 16,
                  //     ),
                  //   ),
                ],
              ),
              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleLabel(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    title: "Precio",
                    bigTitle: priceFormatted.toString(),
                  ),
                  TitleLabel(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    title: "Desc($percentDiscount%)",
                    bigTitle: discountFormatted.toString(),
                  ),
                  const TitleLabel(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    title: "IVA(15%)",
                    bigTitle: "0",
                  ),
                ],
              ),

              const Divider(height: 1),
              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    totalFormatted.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MenuOptions { edit, change, delete }

Future<_MenuOptions?> _showContextMenu(BuildContext context, Offset position) async {
  final result = await showMenu<_MenuOptions>(
    context: context,
    position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
    items: [
      const PopupMenuItem(
        value: _MenuOptions.edit,
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text('Editar'),
        ),
      ),
      const PopupMenuItem(
        value: _MenuOptions.change,
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text('Cambiar'),
        ),
      ),
      const PopupMenuItem(
        value: _MenuOptions.delete,
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text('Eliminar'),
        ),
      ),
    ],
  );

  if (result != null) {
    return result;
  }

  return null;
}
