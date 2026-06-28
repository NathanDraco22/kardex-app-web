import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/elements/elements.dart';

class CustomReceiptListTile extends StatelessWidget {
  const CustomReceiptListTile({
    super.key,
    required this.receipt,
    this.onTap,
    this.trailing,
    this.backgroundColor,
  });

  final ReceiptInDb receipt;
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
                child: ReceiptShortInfo(receipt: receipt),
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
