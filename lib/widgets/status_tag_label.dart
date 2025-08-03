import 'package:flutter/material.dart';

class StatusTagLabel extends StatelessWidget {
  const StatusTagLabel({
    super.key,
    this.isActive = true,
    this.label = "Activo",
  });

  final bool isActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    Color color = isActive ? Colors.green.shade200 : Colors.red.shade200;
    Color fontColor = isActive ? Colors.green.shade800 : Colors.red.shade800;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: fontColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
