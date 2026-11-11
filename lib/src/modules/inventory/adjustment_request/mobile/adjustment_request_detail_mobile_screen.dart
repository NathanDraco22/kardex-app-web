import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_actions.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_item_cards.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_status_chip.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_totals_bar.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adjust_entry_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adjust_exit_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestDetailMobileScreen extends StatelessWidget {
  const AdjustmentRequestDetailMobileScreen({
    super.key,
    required this.request,
  });

  final AdjustmentRequestInDb request;

  String _branchName() {
    try {
      return getIt<AuthCubit>().getBranchById(request.branchId).name;
    } catch (_) {
      return request.branchId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(request.createdAt);

    return Scaffold(
      appBar: AppBar(title: Text('Solicitud ${request.docNumber}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Solicitud ${request.docNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      AdjustmentRequestStatusChip(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _MobileInfoRow(label: 'Sucursal', value: _branchName()),
                  _MobileInfoRow(
                    label: 'Fecha',
                    value: '${DateTimeTool.formatddMMyy(createdAt)} ${DateTimeTool.formatHHmm(createdAt)}',
                  ),
                  _MobileInfoRow(label: 'Creada por', value: request.createdBy.name),
                  if (request.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppThemeTokens.surfaceLight,
                        borderRadius: AppThemeTokens.borderRadiusSm,
                      ),
                      child: Text(
                        request.description,
                        style: const TextStyle(fontSize: 12.5, height: 1.35),
                      ),
                    ),
                  ],
                  if (request.status == AdjustmentRequestStatus.approved) ...[
                    const SizedBox(height: 10),
                    _ApprovedInfo(request: request),
                  ],
                  if (request.status == AdjustmentRequestStatus.cancelled) ...[
                    const SizedBox(height: 10),
                    _CancelledInfo(request: request),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (request.items.isEmpty)
            const Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('La solicitud no tiene productos.')),
              ),
            )
          else
            AdjustmentRequestItemCards(items: request.items),
          const SizedBox(height: 10),
          AdjustmentRequestTotalsBar(
            itemCount: request.items.length,
            entryTotal: request.entryTotal,
            exitTotal: request.exitTotal,
            compact: true,
          ),
          const SizedBox(height: 14),
          AdjustmentRequestActions(request: request, compact: true),
        ],
      ),
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  const _MobileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.neutral,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedInfo extends StatelessWidget {
  const _ApprovedInfo({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    final approvedAt = request.approvedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(request.approvedAt!);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppThemeTokens.success.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusSm,
        border: Border.all(color: AppThemeTokens.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MobileInfoRow(label: 'Aprobada por', value: request.approvedBy?.name ?? '—'),
          if (approvedAt != null)
            _MobileInfoRow(
              label: 'Aprobada el',
              value: '${DateTimeTool.formatddMMyy(approvedAt)} ${DateTimeTool.formatHHmm(approvedAt)}',
            ),
          if (request.adjustEntryId != null) ...[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => showAdjustEntryViewerDialogFromId(context, request.adjustEntryId!),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
              label: Text('Ver entrada ${request.adjustEntryDocNumber ?? ''}'),
            ),
          ],
          if (request.adjustExitId != null) ...[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => showAdjustExitViewerDialogFromId(context, request.adjustExitId!),
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 17),
              label: Text('Ver salida ${request.adjustExitDocNumber ?? ''}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CancelledInfo extends StatelessWidget {
  const _CancelledInfo({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    final cancelledAt = request.cancelledAt == null ? null : DateTime.fromMillisecondsSinceEpoch(request.cancelledAt!);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppThemeTokens.danger.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusSm,
        border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MobileInfoRow(label: 'Cancelada por', value: request.cancelledBy?.name ?? '—'),
          if (cancelledAt != null)
            _MobileInfoRow(
              label: 'Cancelada el',
              value: '${DateTimeTool.formatddMMyy(cancelledAt)} ${DateTimeTool.formatHHmm(cancelledAt)}',
            ),
          if ((request.cancellationReason ?? '').isNotEmpty)
            _MobileInfoRow(label: 'Motivo', value: request.cancellationReason!),
        ],
      ),
    );
  }
}
