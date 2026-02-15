import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

class SaleItemRow extends StatefulWidget {
  const SaleItemRow({
    super.key,
    required this.saleItem,
    this.color,
    this.onTap,
    @Deprecated("Use other opcions") this.onLongPress,
    this.onEdit,
    this.onRemove,
  });

  final SaleItem saleItem;
  final Color? color;
  final void Function()? onTap;

  final void Function()? onLongPress;
  final void Function()? onEdit;
  final void Function()? onRemove;

  @override
  State<SaleItemRow> createState() => _SaleItemRowState();
}

class _SaleItemRowState extends State<SaleItemRow> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: () async {
            final res = await _showContextMenu(context, offset);
            if (res == null) return;
            switch (res) {
              case _MenuOptions.edit:
                widget.onEdit?.call();
              case _MenuOptions.delete:
                widget.onRemove?.call();
            }
          },
          onTapDown: (details) {
            offset = details.globalPosition;
          },
          child: Ink(
            decoration: BoxDecoration(color: widget.color),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Center(
                    child: Text(
                      widget.saleItem.quantity.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.saleItem.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(widget.saleItem.product.brandName),
                          ),

                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(widget.saleItem.product.unitName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final price = NumberFormatter.convertToMoneyLike(
                          widget.saleItem.total,
                        );
                        return Text(
                          price,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _MenuOptions { edit, delete }

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
