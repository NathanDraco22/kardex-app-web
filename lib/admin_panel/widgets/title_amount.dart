import 'package:flutter/material.dart';

class TitleAmount extends StatelessWidget {
  const TitleAmount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Ventas Hoy",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "C\$ 1,000.00",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
