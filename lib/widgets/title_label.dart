import 'package:flutter/material.dart';

class TitleLabel extends StatelessWidget {
  const TitleLabel({
    super.key,
    required this.title,
    required this.bigTitle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String title;
  final String bigTitle;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(title),
        Text(
          bigTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
