import 'package:flutter/material.dart';

class TitleLabel extends StatelessWidget {
  const TitleLabel({
    super.key,
    this.spacing = 0.0,
    required this.title,
    required this.bigTitle,
    this.bigTitleColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final double spacing;
  final String title;
  final String bigTitle;
  final Color? bigTitleColor;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      children: [
        Text(title),
        Text(
          bigTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: bigTitleColor,
          ),
        ),
      ],
    );
  }
}
