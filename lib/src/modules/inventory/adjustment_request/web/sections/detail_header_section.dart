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
    final formattedDate = '${DateTimeTool.formatddMMyy(createdAt)} ${DateTimeTool.formatHHmm(createdAt)}';

    return Row(
      children: [
        // Tarjeta Izquierda (380px fija)
        SizedBox(
          width: 380,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TitleTextField(
                    title: 'Sucursal',
                    initialValue: _branchName(),
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: TitleTextField(
                          title: 'Fecha Doc',
                          initialValue: formattedDate,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TitleTextField(
                          title: 'Creada por',
                          initialValue: request.createdBy.name,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tarjeta Derecha (Flexible)
        Flexible(
          fit: FlexFit.tight,
          child: Card(
            margin: EdgeInsets.zero,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Solicitud ${request.docNumber}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                AdjustmentRequestStatusChip(status: request.status),
                              ],
                            ),
                          ),
                          const Flexible(child: SizedBox.expand()),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AdjustmentRequestActions(request: request),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: FractionallySizedBox(
                              heightFactor: 1.0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: TitleTextField(
                                  title: 'Observaciones',
                                  maxLines: 2,
                                  initialValue: request.description.isEmpty ? 'Sin observaciones' : request.description,
                                  readOnly: true,
                                ),
                              ),
                            ),
                          ),
                          if (request.status == AdjustmentRequestStatus.approved) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: FractionallySizedBox(
                                heightFactor: 1.0,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _ApprovedPanel(request: request),
                                ),
                              ),
                            ),
                          ] else if (request.status == AdjustmentRequestStatus.cancelled) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: FractionallySizedBox(
                                heightFactor: 1.0,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _CancelledPanel(request: request),
                                ),
                              ),
                            ),
                          ] else
                            const Flexible(child: SizedBox.expand()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeTokens.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemeTokens.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 14, color: AppThemeTokens.success),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Aprobado por: ${request.approvedBy?.name ?? "—"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppThemeTokens.success,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (approvedAt != null) ...[
            const SizedBox(height: 2),
            Text(
              '${DateTimeTool.formatddMMyy(approvedAt)} ${DateTimeTool.formatHHmm(approvedAt)}',
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
            ),
          ],
          if (request.adjustEntryId != null || request.adjustExitId != null) ...[
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (request.adjustEntryId != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => showAdjustEntryViewerDialogFromId(context, request.adjustEntryId!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Entrada #${request.adjustEntryDocNumber ?? ""}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (request.adjustEntryId != null && request.adjustExitId != null) const SizedBox(height: 4),
                if (request.adjustExitId != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => showAdjustExitViewerDialogFromId(context, request.adjustExitId!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Salida #${request.adjustExitDocNumber ?? ""}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeTokens.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_rounded, size: 14, color: AppThemeTokens.danger),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Cancelado por: ${request.cancelledBy?.name ?? "—"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppThemeTokens.danger,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (cancelledAt != null) ...[
            const SizedBox(height: 2),
            Text(
              '${DateTimeTool.formatddMMyy(cancelledAt)} ${DateTimeTool.formatHHmm(cancelledAt)}',
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
            ),
          ],
          if ((request.cancellationReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Motivo: ${request.cancellationReason!}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
