import 'package:flutter/material.dart';

class TitleLabel extends StatelessWidget {
  const TitleLabel({super.key, required this.title, required this.bigTitle});

  final String title;
  final String bigTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Text(
          bigTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
