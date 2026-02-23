import 'package:flutter/material.dart';

class MarkerPoint extends StatelessWidget {
  const MarkerPoint({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final firstLetter = title.substring(0, 1).toUpperCase();
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: title,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: primaryColor,
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
