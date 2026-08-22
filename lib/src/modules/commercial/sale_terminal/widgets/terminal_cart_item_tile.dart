import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class TerminalCartItemTile extends StatelessWidget {
  const TerminalCartItemTile({
    super.key,
    required this.item,
    required this.backgroundColor,
    required this.onRemove,
    required this.onEdit,
    required this.onQuantityIncrement,
    required this.onQuantityDecrement,
  });

  final CommercialProductResult item;
  final Color backgroundColor;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final VoidCallback? onQuantityIncrement;
  final VoidCallback? onQuantityDecrement;

  @override
  Widget build(BuildContext context) {
    final unitPrice = NumberFormatter.convertToMoneyLike(
      item.newPrice * item.conversionFactor,
    );
    final total = NumberFormatter.convertToMoneyLike(item.total);
    final isZeroPrice = item.newPrice <= 0;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      color: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isZeroPrice ? Colors.red.shade300 : Colors.grey.shade300,
          width: isZeroPrice ? 1.5 : 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        canRequestFocus: false,
        onLongPress: () async {
          final box = context.findRenderObject() as RenderBox?;
          final position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
          final size = box?.size ?? Size.zero;
          final anchor = position + size.center(Offset.zero);
          final action = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(anchor.dx, anchor.dy, anchor.dx, anchor.dy),
            items: const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  title: Text("Editar"),
                  leading: Icon(Icons.edit_outlined),
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  title: Text("Eliminar", style: TextStyle(color: Colors.red)),
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          );
          if (!context.mounted) return;
          if (action == 'edit') onEdit();
          if (action == 'remove') onRemove();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 66,
                      height: 66,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: ImageViewerWidget(
                          imageUrls: item.product.image.isNotEmpty ? [item.product.image] : [],
                          width: 66,
                          height: 66,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.qr_code, size: 12, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                item.product.displayCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onRemove,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(Icons.close, size: 18, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.15,
                          ),
                        ),
                        if (item.product.brandName.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            item.product.brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: UnitDisplayer(
                                unitName: item.selectedUnitName,
                                conversionFactor: item.conversionFactor,
                                fallbackUnitName: item.product.unitName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              unitPrice,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton(
                    onPressed: onQuantityDecrement,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Icon(Icons.remove, size: 18),
                  ),
                  SizedBox(
                    width: 38,
                    child: Center(
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: onQuantityIncrement,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    total,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade800,
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
