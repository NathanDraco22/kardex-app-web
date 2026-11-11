import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_actions.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_item_cards.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_status_chip.dart';
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
    final netTotal = request.entryTotal - request.exitTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud ${request.docNumber}'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          // Tarjeta Cabecera Bento
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MobileDetailPill(
                          label: 'Sucursal',
                          value: _branchName(),
                          icon: Icons.storefront_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MobileDetailPill(
                          label: 'Fecha Doc',
                          value: '${DateTimeTool.formatddMMyy(createdAt)} ${DateTimeTool.formatHHmm(createdAt)}',
                          icon: Icons.event_note_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _MobileDetailPill(
                    label: 'Creada por',
                    value: request.createdBy.name,
                    icon: Icons.person_outline_rounded,
                  ),
                  if (request.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observaciones',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            request.description,
                            style: const TextStyle(fontSize: 12.5, height: 1.35),
                          ),
                        ],
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

          // Lista de Productos
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

          // Resumen de Totales Integrado
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Productos (${request.items.length}):',
                        style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                      Text(
                        '${request.items.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sobrante:',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        NumberFormatter.convertToMoneyLike(request.entryTotal),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Faltante:',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        NumberFormatter.convertToMoneyLike(request.exitTotal),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Neto:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        NumberFormatter.convertToMoneyLike(netTotal),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: netTotal >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Acciones envueltas en superficie Card
          _MobileActionsCard(request: request),
        ],
      ),
    );
  }
}

class _MobileActionsCard extends StatelessWidget {
  const _MobileActionsCard({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    final actionsWidget = AdjustmentRequestActions(request: request, compact: true);
    // Si no hay acciones disponibles para el usuario o estado, no renderizamos la tarjeta
    if (actionsWidget is SizedBox) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppThemeTokens.neutral,
              ),
            ),
            const SizedBox(height: 10),
            actionsWidget,
          ],
        ),
      ),
    );
  }
}

class _MobileDetailPill extends StatelessWidget {
  const _MobileDetailPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppThemeTokens.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemeTokens.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 16, color: AppThemeTokens.success),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Aprobada por: ${request.approvedBy?.name ?? "—"}',
                  style: const TextStyle(
                    fontSize: 12,
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
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
          if (request.adjustEntryId != null || request.adjustExitId != null) ...[
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (request.adjustEntryId != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      minimumSize: const Size.fromHeight(40),
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => showAdjustEntryViewerDialogFromId(context, request.adjustEntryId!),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: Text('Entrada #${request.adjustEntryDocNumber ?? ""}'),
                  ),
                if (request.adjustEntryId != null && request.adjustExitId != null) const SizedBox(height: 6),
                if (request.adjustExitId != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      minimumSize: const Size.fromHeight(40),
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => showAdjustExitViewerDialogFromId(context, request.adjustExitId!),
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: Text('Salida #${request.adjustExitDocNumber ?? ""}'),
                  ),
              ],
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppThemeTokens.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_rounded, size: 16, color: AppThemeTokens.danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cancelada por: ${request.cancelledBy?.name ?? "—"}',
                  style: const TextStyle(
                    fontSize: 12,
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
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
          if ((request.cancellationReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Motivo: ${request.cancellationReason!}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
            ),
          ],
        ],
      ),
    );
  }
}
