import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

class DevolutionStatusChip extends StatelessWidget {
  const DevolutionStatusChip({
    super.key,
    required this.status,
    this.width,
  });

  final DevolutionStatus status;
  final double? width;

  static const _colorsMap = {
    DevolutionStatus.open: Color(0xFF42A5F5),
    DevolutionStatus.confirmed: Color(0xFF66BB6A),
    DevolutionStatus.cancelled: Color(0xFFEF5350),
    DevolutionStatus.applied: Color(0xFF616161),
  };

  static const _tagMap = {
    DevolutionStatus.open: "Abierta",
    DevolutionStatus.confirmed: "Confirmada",
    DevolutionStatus.cancelled: "Cancelada",
    DevolutionStatus.applied: "Aplicada",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _colorsMap[status],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _tagMap[status] ?? status.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
