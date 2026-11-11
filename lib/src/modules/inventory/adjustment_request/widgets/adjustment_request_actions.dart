import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/read_adjustment_request_detail_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/write_adjustment_request_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_confirm_dialogs.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestActions extends StatelessWidget {
  const AdjustmentRequestActions({
    super.key,
    required this.request,
    this.compact = false,
  });

  final AdjustmentRequestInDb request;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().user;
    if (user == null) return const SizedBox.shrink();

    final isCreator = user.id == request.createdBy.id;
    final isAdmin = user.id == 'root' || user.role == 'Admin';
    final isSupervisor = user.role == 'Supervisor';
    final isPending = request.status == AdjustmentRequestStatus.pending;

    final canEdit = isPending && (isCreator || isAdmin);
    final canCancel = isPending && (isCreator || isAdmin);
    final canApprove = isPending && (isAdmin || (isSupervisor && !isCreator));

    if (!canEdit && !canCancel && !canApprove) return const SizedBox.shrink();

    final buttons = <Widget>[
      if (canEdit)
        OutlinedButton.icon(
          onPressed: () async {
            await context.pushNamed(
              RouteNames.adjustmentRequestEdit,
              pathParameters: {'requestId': request.id},
              extra: request,
            );
            if (!context.mounted) return;
            context.read<ReadAdjustmentRequestDetailCubit>().refresh();
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Editar'),
        ),
      if (canCancel)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppThemeTokens.danger,
            side: BorderSide(color: AppThemeTokens.danger.withValues(alpha: 0.45)),
          ),
          onPressed: () async {
            final result = await showCancelAdjustmentRequestDialog(context, request: request);
            if (result == null || !context.mounted) return;

            final user = getIt<AuthCubit>().user;
            if (user == null) return;
            await context.read<WriteAdjustmentRequestCubit>().cancel(
              request.id,
              UserInfo(id: user.id, name: user.username),
              reason: result.reason,
            );
          },
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('Cancelar'),
        ),
      if (canApprove)
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppThemeTokens.success),
          onPressed: () async {
            final confirmed = await showApproveAdjustmentRequestDialog(context, request: request);
            if (!confirmed || !context.mounted) return;

            final user = getIt<AuthCubit>().user;
            if (user == null) return;
            await context.read<WriteAdjustmentRequestCubit>().approve(
              request.id,
              UserInfo(id: user.id, name: user.username),
            );
          },
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Aprobar'),
        ),
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < buttons.length; index++) ...[
            SizedBox(height: 42, child: buttons[index]),
            if (index < buttons.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }
}
