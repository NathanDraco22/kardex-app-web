part of '../adjustment_request_detail_web_screen.dart';

class _DetailHeaderSection extends StatelessWidget {
  const _DetailHeaderSection({required this.request});

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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Solicitud ${request.docNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      AdjustmentRequestStatusChip(status: request.status),
                    ],
                  ),
                ),
                AdjustmentRequestActions(request: request),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 28,
              runSpacing: 10,
              children: [
                _DetailInfo(label: 'Sucursal', value: _branchName()),
                _DetailInfo(label: 'Creada por', value: request.createdBy.name),
                _DetailInfo(
                  label: 'Fecha',
                  value: '${DateTimeTool.formatddMMyy(createdAt)} ${DateTimeTool.formatHHmm(createdAt)}',
                ),
              ],
            ),
            if (request.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppThemeTokens.surfaceLight,
                  borderRadius: AppThemeTokens.borderRadiusMd,
                ),
                child: Text(
                  request.description,
                  style: const TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFF334155)),
                ),
              ),
            ],
            if (request.status == AdjustmentRequestStatus.approved) ...[
              const SizedBox(height: 12),
              _ApprovedPanel(request: request),
            ],
            if (request.status == AdjustmentRequestStatus.cancelled) ...[
              const SizedBox(height: 12),
              _CancelledPanel(request: request),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  const _DetailInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.neutral,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}

class _ApprovedPanel extends StatelessWidget {
  const _ApprovedPanel({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    final approvedAt = request.approvedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(request.approvedAt!);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppThemeTokens.success.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.success.withValues(alpha: 0.25)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _DetailInfo(label: 'Aprobada por', value: request.approvedBy?.name ?? '—'),
          if (approvedAt != null)
            _DetailInfo(
              label: 'Fecha de aprobación',
              value: '${DateTimeTool.formatddMMyy(approvedAt)} ${DateTimeTool.formatHHmm(approvedAt)}',
            ),
          if (request.adjustEntryId != null)
            OutlinedButton.icon(
              onPressed: () => showAdjustEntryViewerDialogFromId(context, request.adjustEntryId!),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text('Entrada ${request.adjustEntryDocNumber ?? ''}'),
            ),
          if (request.adjustExitId != null)
            OutlinedButton.icon(
              onPressed: () => showAdjustExitViewerDialogFromId(context, request.adjustExitId!),
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
              label: Text('Salida ${request.adjustExitDocNumber ?? ''}'),
            ),
        ],
      ),
    );
  }
}

class _CancelledPanel extends StatelessWidget {
  const _CancelledPanel({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    final cancelledAt = request.cancelledAt == null ? null : DateTime.fromMillisecondsSinceEpoch(request.cancelledAt!);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppThemeTokens.danger.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.25)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        children: [
          _DetailInfo(label: 'Cancelada por', value: request.cancelledBy?.name ?? '—'),
          if (cancelledAt != null)
            _DetailInfo(
              label: 'Fecha de cancelación',
              value: '${DateTimeTool.formatddMMyy(cancelledAt)} ${DateTimeTool.formatHHmm(cancelledAt)}',
            ),
          if ((request.cancellationReason ?? '').isNotEmpty)
            _DetailInfo(label: 'Motivo', value: request.cancellationReason!),
        ],
      ),
    );
  }
}
