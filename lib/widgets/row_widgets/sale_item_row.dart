import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

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
      height: 70,
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
                    child: Builder(
                      builder: (context) {
                        final displayQty = widget.saleItem.conversionFactor != 1
                            ? (widget.saleItem.quantity ~/ widget.saleItem.conversionFactor).toString()
                            : widget.saleItem.quantity.toString();
                        return Text(
                          displayQty,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
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
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          Text(
                            widget.saleItem.product.code ?? "",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        widget.saleItem.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                        final price = NumberFormatter.convertFromCentsToUnitsCurrency(
                          widget.saleItem.total,
                        );
                        return Text(
                          price,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
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
