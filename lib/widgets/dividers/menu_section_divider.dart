import 'package:flutter/material.dart';

class MenuSectionDivider extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  final bool isFirst;

  const MenuSectionDivider({
    super.key,
    required this.title,
    this.padding,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.fromLTRB(
          16,
          isFirst ? 14 : 24,
          16,
          8,
        );

    return Padding(
      padding: effectivePadding,
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
