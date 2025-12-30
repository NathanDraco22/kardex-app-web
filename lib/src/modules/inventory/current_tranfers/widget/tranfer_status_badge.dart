import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';

class TranferStatusBadge extends StatelessWidget {
  const TranferStatusBadge({super.key, required this.status});

  final TransferStatus status;

  @override
  Widget build(BuildContext context) {
    Color tranferColor = switch (status) {
      .cancelled => Colors.red.shade300,
      .inTransit => Colors.amber,
      .received => Colors.green.shade400,
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: tranferColor,
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
