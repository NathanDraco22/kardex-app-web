import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/widgets/elements/elements.dart';

class CustomOrderListTile extends StatelessWidget {
  const CustomOrderListTile({
    super.key,
    required this.order,
    this.onTap,
    this.trailing,
    this.backgroundColor,
  });

  final OrderInDb order;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OrderShortInfo(order: order),
              ),

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
