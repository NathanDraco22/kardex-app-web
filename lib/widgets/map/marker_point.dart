import 'package:flutter/material.dart';

class MarkerPoing extends StatelessWidget {
  const MarkerPoing({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final firstLetter = title.substring(0, 1).toUpperCase();
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: title,
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
    );
  }
}
