import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestStatusChip extends StatelessWidget {
  const AdjustmentRequestStatusChip({
    super.key,
    required this.status,
    this.isFilled = false,
  });

  final AdjustmentRequestStatus status;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      AdjustmentRequestStatus.pending => AppStatusBadge(
        label: 'Pendiente',
        icon: Icons.hourglass_top_rounded,
        variant: AppBadgeVariant.warning,
        isFilled: isFilled,
      ),
      AdjustmentRequestStatus.approved => AppStatusBadge(
        label: 'Aprobada',
        icon: Icons.check_circle_outline_rounded,
        variant: AppBadgeVariant.success,
        isFilled: isFilled,
      ),
      AdjustmentRequestStatus.cancelled => AppStatusBadge(
        label: 'Cancelada',
        icon: Icons.cancel_outlined,
        variant: AppBadgeVariant.danger,
        isFilled: isFilled,
      ),
    };
  }
}
