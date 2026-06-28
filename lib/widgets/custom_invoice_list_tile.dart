import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/elements/elements.dart';

class CustomInvoiceListTile extends StatelessWidget {
  const CustomInvoiceListTile({
    super.key,
    required this.invoice,
    this.onTap,
    this.trailing,
    this.backgroundColor,
  });

  final InvoiceInDb invoice;
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
                child: InvoiceShortInfo(invoice: invoice),
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
