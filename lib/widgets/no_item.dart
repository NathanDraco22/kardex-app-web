import 'package:flutter/material.dart';

class NoItemWidget extends StatelessWidget {
  const NoItemWidget({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 100,
          color: Colors.grey.shade400,
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
