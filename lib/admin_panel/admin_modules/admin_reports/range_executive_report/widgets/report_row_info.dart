import 'package:flutter/material.dart';

class ReportRowInfo extends StatelessWidget {
  const ReportRowInfo(
    this.label,
    this.value, {
    super.key,
    this.isHighlight = false,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final bool isHighlight;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ?? const TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? theme.colorScheme.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}
